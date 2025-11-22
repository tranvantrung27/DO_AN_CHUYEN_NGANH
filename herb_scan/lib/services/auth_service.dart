import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/index.dart';
import 'notification/notification_service.dart';
import 'notification/notification_badge_service.dart';

/// Service xử lý authentication với Firebase
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Cấu hình Google Sign In với scopes để luôn hiển thị consent screen
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    // Force hiển thị account picker mỗi lần sign in
    forceCodeForRefreshToken: true,
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy user hiện tại
  User? get currentUser => _auth.currentUser;

  /// Stream theo dõi auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Đăng nhập bằng email và password
  Future<AuthResult> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (credential.user != null) {
        return AuthResult.success(credential.user);
      } else {
        return AuthResult.failure(message: 'Đăng nhập thất bại');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        message: _getErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      return AuthResult.failure(message: 'Có lỗi xảy ra: $e');
    }
  }

  /// Kiểm tra số điện thoại đã được đăng ký chưa
  Future<bool> isPhoneNumberRegistered(String phoneNumber) async {
    try {
      // Format phone number - thử cả format +84 và format 0
      String phoneWithoutPrefix = phoneNumber;
      if (phoneNumber.startsWith('0')) {
        phoneWithoutPrefix = phoneNumber.substring(1); // Bỏ số 0 đầu
      } else if (phoneNumber.startsWith('+84')) {
        phoneWithoutPrefix = phoneNumber.substring(3); // Bỏ +84
      } else if (phoneNumber.startsWith('84')) {
        phoneWithoutPrefix = phoneNumber.substring(2); // Bỏ 84
      }
      
      String formattedPhone1 = '+84$phoneWithoutPrefix'; // Format 1: +84334666030
      String formattedPhone2 = '0$phoneWithoutPrefix';   // Format 2: 0334666030

      // Kiểm tra format +84
      final querySnapshot1 = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedPhone1)
          .limit(1)
          .get();

      // Kiểm tra format 0
      final querySnapshot2 = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedPhone2)
          .limit(1)
          .get();

      final isInFirestore = querySnapshot1.docs.isNotEmpty || querySnapshot2.docs.isNotEmpty;

      // Chỉ kiểm tra Firestore vì Firebase Auth không hỗ trợ fetchSignInMethodsForEmail với phone number
      return isInFirestore;
    } catch (e) {
      return false;
    }
  }

  /// Kiểm tra và cấu hình Firebase SMS Template
  Future<void> _configureSMSTemplate() async {
    try {
      // Firebase sẽ tự động sử dụng template đã cấu hình trong Console
      // Template: <#> %APP_NAME%: Mã xác thực của bạn là %LOGIN_CODE%.
      // Không chia sẻ mã này cho bất kỳ ai.
    } catch (e) {
      // Ignore
    }
  }

  /// Kiểm tra và cấu hình Firebase Password Reset SMS Template
  Future<void> _configurePasswordResetTemplate() async {
    try {
      // Firebase sẽ tự động sử dụng template đã cấu hình trong Console
      // Template: %LOGIN_CODE% là mã đặt lại mật khẩu của bạn cho %APP_NAME%.
    } catch (e) {
      // Ignore
    }
  }

  /// Gửi OTP đến số điện thoại (Hỗ trợ cả Mock Mode và Real Firebase)
  Future<AuthResult> sendPhoneOTP(String phoneNumber) async {
    try {
      // Format phone number
      String formattedPhone = phoneNumber;
      if (phoneNumber.startsWith('0') && phoneNumber.length == 10) {
        formattedPhone = '+84${phoneNumber.substring(1)}';
      } else if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+84$phoneNumber';
      }
      
      // Kiểm tra số điện thoại đã được đăng ký chưa
      final isRegistered = await isPhoneNumberRegistered(formattedPhone);
      if (isRegistered) {
        return AuthResult.failure(
          message: 'Số điện thoại này đã được đăng ký. Vui lòng đăng nhập thay vì đăng ký mới.',
          code: 'phone-already-registered'
        );
      }
      
      // Danh sách test phone numbers cho Mock Mode (chỉ dành cho development)
      final testPhones = [
        '0123456789',
        '+84123456789', 
        '0389399195',
        '+84987654321',
      ];
      
      // Kiểm tra nếu là test phone number
      if (testPhones.contains(phoneNumber) || testPhones.contains(formattedPhone)) {
        return AuthResult.success(
          null, 
          verificationId: 'mock_verification_${phoneNumber}_${DateTime.now().millisecondsSinceEpoch}'
        );
      }
      
      // Firebase Phone Auth thật
      String? verificationId;
      
      // Cấu hình SMS Template
      await _configureSMSTemplate();
      
      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: formattedPhone,
          verificationCompleted: (PhoneAuthCredential credential) {
            // Auto verification completed
            verificationId = 'auto_verified';
          },
          verificationFailed: (FirebaseAuthException e) {
            // Không throw exception ở đây, để xử lý ở catch block
          },
          codeSent: (String verificationIdParam, int? resendToken) {
            verificationId = verificationIdParam;
          },
          codeAutoRetrievalTimeout: (String verificationIdParam) {
            verificationId = verificationIdParam;
          },
          timeout: const Duration(seconds: 30), // Giảm từ 60 xuống 30 giây
        );
      
      // Chờ verification ID với timeout ngắn để đảm bảo có ID thật
      int attempts = 0;
      while (verificationId == null && attempts < 50) { // 5 giây
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      
      if (verificationId != null) {
        return AuthResult.success(
          null, 
          verificationId: verificationId!
        );
      } else {
        return AuthResult.failure(message: 'Timeout: Không nhận được verification ID');
      }
      
    } catch (e) {
      // Nếu Firebase Phone Auth thất bại, fallback về Mock Mode
      if (e is FirebaseAuthException) {
        // Xử lý đặc biệt cho lỗi blocked
        if (e.message?.contains('blocked all requests') == true) {
          return AuthResult.failure(
            message: 'Bạn đã thực hiện quá nhiều thao tác. Vui lòng thử lại sau',
            code: 'device-blocked',
          );
        }
        
        // Nếu OTP đã được gửi nhưng có lỗi khác, vẫn cho phép verify
        if (e.code == 'too-many-requests' || e.code == 'invalid-phone-number') {
          return AuthResult.failure(
            message: 'Bạn đã thực hiện quá nhiều thao tác. Vui lòng thử lại sau',
            code: e.code,
          );
        } else {
          // Các lỗi khác có thể vẫn cho phép OTP được gửi
          return AuthResult.success(
            null, 
            verificationId: 'fallback_verification_${DateTime.now().millisecondsSinceEpoch}'
          );
        }
      }
      return AuthResult.failure(message: 'Có lỗi xảy ra: $e');
    }
    
    } catch (e) {
      return AuthResult.failure(message: 'Có lỗi xảy ra: $e');
    }
  }

  /// Xác thực OTP để đăng nhập (user đã tồn tại)
  Future<AuthResult> verifyPhoneOTPForLogin({
    required String verificationId,
    required String otp,
  }) async {
    try {
      // Mock mode cho development
      if (verificationId.startsWith('mock_verification_')) {
        if (otp == '123456') {
          // Mock success
          return AuthResult.success(null);
        } else {
          return AuthResult.failure(message: 'Mã OTP không đúng. Sử dụng 123456 cho mock mode.');
        }
      }
      
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      
      // Sign in với credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        return AuthResult.success(userCredential.user);
      } else {
        return AuthResult.failure(message: 'Xác thực OTP thất bại');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        message: _getErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      return AuthResult.failure(message: 'Có lỗi xảy ra: $e');
    }
  }

  /// Xác thực OTP và tạo tài khoản
  Future<AuthResult> verifyPhoneOTP({
    required String verificationId,
    required String otp,
    required String displayName,
  }) async {
    try {
      // Mock mode cho development
      if (verificationId.startsWith('mock_verification_')) {
        if (otp == '123456') {
          // Mock success - tạo user giả
          return AuthResult.success(null);
        } else {
          return AuthResult.failure(message: 'Mã OTP không đúng. Sử dụng 123456 cho mock mode.');
        }
      }
      
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Cập nhật display name
        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.reload();
        
        // Lưu thông tin user vào Firestore
        await _saveUserToFirestore(
          userCredential.user!,
          phoneNumber: userCredential.user!.phoneNumber ?? '',
          displayName: displayName,
        );
        
        // Gửi thông báo đăng ký thành công
        await NotificationService.sendRegistrationSuccessNotification(
          phoneNumber: userCredential.user!.phoneNumber ?? '',
          displayName: displayName,
        );
        
        // Đặt lastNotificationViewedTime = thời điểm hiện tại cho user mới
        // Để chỉ hiển thị thông báo cho các bài mới từ sau thời điểm đăng ký
        await NotificationBadgeService.markAsViewed();
        
        return AuthResult.success(userCredential.user);
      } else {
        return AuthResult.failure(message: 'Xác thực OTP thất bại');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        message: _getErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      return AuthResult.failure(message: 'Có lỗi xảy ra: $e');
    }
  }

  /// Đăng nhập bằng số điện thoại và password
  Future<AuthResult> signInWithPhonePassword({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      // Chuẩn hóa số điện thoại để kiểm tra (bỏ prefix, chỉ lấy 9 số cuối)
      String phoneWithoutPrefix = phoneNumber;
      if (phoneNumber.startsWith('+84')) {
        phoneWithoutPrefix = phoneNumber.substring(3); // Bỏ +84, lấy 9 số cuối
      } else if (phoneNumber.startsWith('0')) {
        phoneWithoutPrefix = phoneNumber.substring(1); // Bỏ số 0 đầu, lấy 9 số cuối
      } else if (phoneNumber.startsWith('84')) {
        phoneWithoutPrefix = phoneNumber.substring(2); // Bỏ 84, lấy 9 số cuối
      }
      
      String formattedPhone1 = '+84$phoneWithoutPrefix'; // Format 1: +84334666030
      String formattedPhone2 = '0$phoneWithoutPrefix';   // Format 2: 0334666030

      // Kiểm tra format +84
      var exactQuery1 = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedPhone1)
          .limit(1)
          .get();

      // Kiểm tra format 0
      var exactQuery2 = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedPhone2)
          .limit(1)
          .get();

      QuerySnapshot<Map<String, dynamic>>? exactQuery;
      String finalFormattedPhone = formattedPhone1;

      if (exactQuery1.docs.isNotEmpty) {
        exactQuery = exactQuery1;
        finalFormattedPhone = formattedPhone1;
      } else if (exactQuery2.docs.isNotEmpty) {
        exactQuery = exactQuery2;
        finalFormattedPhone = formattedPhone2;
      }

      if (exactQuery != null && exactQuery.docs.isNotEmpty) {
        // Số điện thoại chính xác có trên Firebase → kiểm tra password
        final userDoc = exactQuery.docs.first;
        final userData = userDoc.data();
        final storedPassword = userData['password'] as String?;
        final uid = userData['uid'] as String?;

        if (uid == null) {
          return AuthResult.failure(message: 'Tài khoản chưa được đăng ký');
        }

        // Kiểm tra password
        if (storedPassword == null || storedPassword != password) {
          return AuthResult.failure(
            message: 'Tài khoản hoặc mật khẩu không đúng',
            code: 'wrong-password'
          );
        }
      } else {
        // Số điện thoại chính xác KHÔNG có trên Firebase
        return AuthResult.failure(
          message: 'Tài khoản chưa được đăng ký',
          code: 'phone-not-found'
        );
      }

      // Nếu đến đây, password đã đúng và số điện thoại tồn tại
      // (Đã kiểm tra trong if block trên)
      final userDoc = exactQuery.docs.first;
      final userData = userDoc.data();
      final uid = userData['uid'] as String?;

      if (uid == null) {
        return AuthResult.failure(message: 'Tài khoản chưa được đăng ký');
      }

      // Kiểm tra user đã authenticated trong Firebase Auth chưa
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == uid) {
        // User đã authenticated, cho phép đăng nhập
        return AuthResult.success(currentUser);
      }

      // User chưa authenticated, cần verify phone bằng OTP trước
      // Gửi OTP để verify phone và sign in
      final otpResult = await sendPhoneOTP(finalFormattedPhone);
      
      if (otpResult.isSuccess && otpResult.verificationId != null) {
        // Trả về verificationId để user nhập OTP
        return AuthResult.success(
          null,
          verificationId: otpResult.verificationId!,
        );
      } else {
        return AuthResult.failure(
          message: otpResult.errorMessage ?? 'Không thể gửi mã OTP',
        );
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        message: _getErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      return AuthResult.failure(message: 'Có lỗi xảy ra: $e');
    }
  }

  /// Đăng ký bằng email và password
  Future<AuthResult> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (credential.user != null) {
        // Cập nhật display name
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
        
        // Lưu thông tin user vào Firestore (nếu chưa có)
        await _saveUserToFirestore(
          credential.user!,
          phoneNumber: '',
          displayName: displayName,
        );
        
        // Đặt lastNotificationViewedTime = thời điểm hiện tại cho user mới
        // Để chỉ hiển thị thông báo cho các bài mới từ sau thời điểm đăng ký
        await NotificationBadgeService.markAsViewed();
        
        return AuthResult.success(credential.user);
      } else {
        return AuthResult.failure(message: 'Đăng ký thất bại');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        message: _getErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      return AuthResult.failure(message: 'Có lỗi xảy ra: $e');
    }
  }

  /// Đăng nhập bằng Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Sign out Google trước để clear cache và force hiển thị account picker
      // Lưu ý: Consent screen chỉ hiển thị nếu user chưa từng cho phép app
      // Nếu user đã cho phép app trước đó, Google sẽ không hiển thị lại consent screen (theo Google policy)
      try {
        // Kiểm tra xem có account nào đang cached không
        final currentGoogleUser = await _googleSignIn.signInSilently();
        if (currentGoogleUser != null) {
          // Có account cached → sign out để force hiển thị account picker
          await _googleSignIn.signOut();
          // Đợi một chút để đảm bảo sign out hoàn tất
          await Future.delayed(const Duration(milliseconds: 200));
        }
      } catch (e) {
        // Không có account cached hoặc lỗi → tiếp tục
      }
      
      // Trigger the authentication flow
      // Với forceCodeForRefreshToken: true, Google Sign In sẽ:
      // 1. Luôn hiển thị account picker để user chọn account
      // 2. Hiển thị OAuth consent screen nếu user chưa từng cho phép app
      //    (Nếu user đã cho phép app trước đó, consent screen sẽ không hiển thị lại - đây là hành vi bình thường của Google)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return AuthResult.failure(message: 'Đăng nhập Google bị hủy');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        final user = userCredential.user!;
        
        // Kiểm tra xem user đã tồn tại trong Firestore chưa
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        final isNewUser = !userDoc.exists;
        
            if (isNewUser) {
              // User mới → lưu vào Firestore và set lastNotificationViewedTime
              await _saveUserToFirestore(
                user,
                phoneNumber: '',
                displayName: user.displayName ?? user.email?.split('@')[0] ?? 'User',
              );
              
              // Đặt lastNotificationViewedTime = thời điểm hiện tại cho user mới
              // Để chỉ hiển thị thông báo cho các bài mới từ sau thời điểm đăng ký
              await NotificationBadgeService.markAsViewed();
            }
        
        return AuthResult.success(user);
      } else {
        return AuthResult.failure(message: 'Đăng nhập Google thất bại');
      }
    } catch (e) {
      return AuthResult.failure(message: 'Có lỗi xảy ra: $e');
    }
  }

  /// Đăng xuất
  Future<AuthResult> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return AuthResult.success(null);
    } catch (e) {
      return AuthResult.failure(message: 'Có lỗi khi đăng xuất: $e');
    }
  }

  /// Reset password bằng email
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        message: _getErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      return AuthResult.failure(message: 'Có lỗi xảy ra: $e');
    }
  }

  /// Reset password bằng SMS (Phone Number)
  Future<AuthResult> resetPasswordBySMS(String phoneNumber) async {
    try {
      // Format phone number
      String formattedPhone = phoneNumber;
      if (phoneNumber.startsWith('0') && phoneNumber.length == 10) {
        formattedPhone = '+84${phoneNumber.substring(1)}';
      } else if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+84$phoneNumber';
      }

      // Cấu hình Password Reset SMS Template
      await _configurePasswordResetTemplate();

      // Gửi SMS reset password
      String? verificationId;
      
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) {
          verificationId = 'auto_verified';
        },
          verificationFailed: (FirebaseAuthException e) {
            // Ignore
          },
          codeSent: (String verificationIdParam, int? resendToken) {
            verificationId = verificationIdParam;
          },
        codeAutoRetrievalTimeout: (String verificationIdParam) {
          verificationId = verificationIdParam;
        },
        timeout: const Duration(seconds: 30),
      );

      // Wait for verification ID
      int attempts = 0;
      while (verificationId == null && attempts < 30) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      if (verificationId != null) {
        return AuthResult.success(
          null, 
          verificationId: verificationId!
        );
      } else {
        return AuthResult.failure(message: 'Timeout: Không nhận được verification ID');
      }

    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        message: _getErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      return AuthResult.failure(message: 'Có lỗi xảy ra: $e');
    }
  }

  /// Gửi email verification
  Future<AuthResult> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return AuthResult.success(null);
      } else {
        return AuthResult.failure(message: 'Không thể gửi email xác thực');
      }
    } catch (e) {
      return AuthResult.failure(message: 'Có lỗi xảy ra: $e');
    }
  }

  /// Lưu thông tin user vào Firestore
  Future<void> _saveUserToFirestore(
    User user, {
    required String phoneNumber,
    required String displayName,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'phoneNumber': phoneNumber,
        'displayName': displayName,
        'email': user.email,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      }, SetOptions(merge: true));
    } catch (e) {
      // Ignore
    }
  }

  /// Chuyển đổi Firebase error code thành message tiếng Việt
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Tài khoản chưa được đăng ký';
      case 'wrong-password':
        return 'Tài khoản hoặc mật khẩu không đúng';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng';
      case 'phone-not-found':
        return 'Tài khoản chưa được đăng ký';
      case 'phone-auth-required':
        return 'Vui lòng đăng nhập bằng OTP để xác thực số điện thoại';
      case 'invalid-phone-number':
        return 'Số điện thoại không hợp lệ';
      case 'invalid-verification-code':
        return 'Mã xác thực không chính xác';
      case 'invalid-verification-id':
        return 'Mã xác thực không hợp lệ';
      case 'credential-already-in-use':
        return 'Tài khoản này đã được liên kết với phương thức đăng nhập khác';
      case 'account-exists-with-different-credential':
        return 'Tài khoản đã tồn tại với phương thức đăng nhập khác';
      case 'phone-already-registered':
        return 'Số điện thoại này đã được đăng ký. Vui lòng đăng nhập thay vì đăng ký mới.';
      case 'weak-password':
        return 'Mật khẩu quá yếu';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa';
      case 'too-many-requests':
        return 'Bạn đã thực hiện quá nhiều thao tác. Vui lòng thử lại sau';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập này chưa được kích hoạt';
      case 'invalid-credential':
        return 'Thông tin đăng nhập không hợp lệ';
      case 'app-check-token-invalid':
        return 'Ứng dụng chưa được xác thực. Vui lòng thử lại';
      case 'app-check-token-expired':
        return 'Phiên đăng nhập đã hết hạn. Vui lòng thử lại';
      case 'app-check-token-missing':
        return 'Thiếu mã xác thực ứng dụng. Vui lòng thử lại';
      case 'app-check-token-rejected':
        return 'Ứng dụng không được phép truy cập. Vui lòng thử lại';
      case 'app-check-token-error':
        return 'Lỗi xác thực ứng dụng. Vui lòng thử lại';
      case 'app-check-token-unknown':
        return 'Lỗi xác thực không xác định. Vui lòng thử lại';
      case 'blocked':
        return 'Bạn đã thực hiện quá nhiều thao tác. Vui lòng thử lại sau';
      case 'quota-exceeded':
        return 'Bạn đã thực hiện quá nhiều thao tác. Vui lòng thử lại sau';
      case 'unavailable':
        return 'Dịch vụ tạm thời không khả dụng. Vui lòng thử lại sau';
      case 'device-blocked':
        return 'Bạn đã thực hiện quá nhiều thao tác. Vui lòng thử lại sau';
      case 'rate-limit-exceeded':
        return 'Bạn đã thực hiện quá nhiều thao tác. Vui lòng thử lại sau';
      case 'phone-not-registered':
        return 'Số điện thoại chưa được đăng ký';
      default:
        return 'Có lỗi xảy ra. Vui lòng thử lại';
    }
  }

  /// Kiểm tra số điện thoại đã được đăng ký chưa (cho password reset)
  Future<AuthResult> isPhoneNumberRegisteredForReset(String phoneNumber) async {
    try {
      // Format phone number
      String formattedPhone = phoneNumber;
      if (phoneNumber.startsWith('0')) {
        formattedPhone = '+84${phoneNumber.substring(1)}';
      } else if (!phoneNumber.startsWith('+84')) {
        formattedPhone = '+84$phoneNumber';
      }

      // Check in Firestore
      final userQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedPhone)
          .limit(1)
          .get();

      final isRegistered = userQuery.docs.isNotEmpty;

      if (isRegistered) {
        return AuthResult.success(null);
      } else {
        return AuthResult.failure(
          message: 'Số điện thoại chưa được đăng ký',
          code: 'phone-not-registered',
        );
      }
    } catch (e) {
      return AuthResult.failure(message: 'Có lỗi xảy ra khi kiểm tra số điện thoại');
    }
  }

  /// Cập nhật mật khẩu mới cho người dùng
  Future<AuthResult> updatePassword({
    required String phoneNumber,
    required String verificationId,
    required String otp,
    required String newPassword,
  }) async {
    try {
      // Verify OTP first
      final otpResult = await verifyPhoneOTP(
        verificationId: verificationId,
        otp: otp,
        displayName: 'Password Reset User',
      );

      if (!otpResult.isSuccess) {
        return otpResult;
      }

      // Get current user
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return AuthResult.failure(
          message: 'Người dùng chưa đăng nhập',
          code: 'user-not-signed-in',
        );
      }

      // Update password
      await currentUser.updatePassword(newPassword);

      // Update password in Firestore
      await _firestore.collection('users').doc(currentUser.uid).update({
        'password': newPassword,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        message: _getErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      return AuthResult.failure(message: 'Có lỗi xảy ra khi cập nhật mật khẩu');
    }
  }
}
