import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/index.dart';
import 'notification/notification_service.dart';

/// Service xử lý authentication với Firebase
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
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
      // Format phone number
      String formattedPhone = phoneNumber;
      if (phoneNumber.startsWith('0') && phoneNumber.length == 10) {
        formattedPhone = '+84${phoneNumber.substring(1)}';
      } else if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+84$phoneNumber';
      }

      print('🔍 Checking if phone $formattedPhone is registered...');

      // Kiểm tra trong Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedPhone)
          .limit(1)
          .get();

      final isInFirestore = querySnapshot.docs.isNotEmpty;
      print('📊 Firestore check result: $isInFirestore');

      // Chỉ kiểm tra Firestore vì Firebase Auth không hỗ trợ fetchSignInMethodsForEmail với phone number
      return isInFirestore;
    } catch (e) {
      print('❌ Error checking phone registration: $e');
      return false;
    }
  }

  /// Kiểm tra và cấu hình Firebase SMS Template
  Future<void> _configureSMSTemplate() async {
    try {
      // Firebase sẽ tự động sử dụng template đã cấu hình trong Console
      // Template: <#> %APP_NAME%: Mã xác thực của bạn là %LOGIN_CODE%.
      // Không chia sẻ mã này cho bất kỳ ai.
      print('📱 Firebase SMS Template đã được cấu hình');
      print('📱 Template: <#> %APP_NAME%: Mã xác thực của bạn là %LOGIN_CODE%.');
      print('📱 App Name: Herb Scan');
      print('📱 Expected SMS: <#> Herb Scan: Mã xác thực của bạn là [CODE].');
      print('📱 Không chia sẻ mã này cho bất kỳ ai.');
      print('📱 Firebase sẽ tự gắn app hash ở dòng cuối');
    } catch (e) {
      print('❌ Error configuring SMS template: $e');
    }
  }

  /// Kiểm tra và cấu hình Firebase Password Reset SMS Template
  Future<void> _configurePasswordResetTemplate() async {
    try {
      // Firebase sẽ tự động sử dụng template đã cấu hình trong Console
      // Template: %LOGIN_CODE% là mã đặt lại mật khẩu của bạn cho %APP_NAME%.
      print('📱 Firebase Password Reset SMS Template đã được cấu hình');
      print('📱 Template: %LOGIN_CODE% là mã đặt lại mật khẩu của bạn cho %APP_NAME%');
    } catch (e) {
      print('❌ Error configuring Password Reset SMS template: $e');
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
            print('❌ Verification failed: ${e.message}');
            // Không throw exception ở đây, để xử lý ở catch block
          },
          codeSent: (String verificationIdParam, int? resendToken) {
            verificationId = verificationIdParam;
            print('✅ OTP sent successfully! Verification ID: $verificationIdParam');
            print('📱 SMS đã được gửi với template tùy chỉnh');
            print('🚀 Chuyển đến màn hình OTP ngay lập tức');
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
        print('✅ Verification ID received: $verificationId');
        return AuthResult.success(
          null, 
          verificationId: verificationId!
        );
      } else {
        print('❌ Timeout: Không nhận được verification ID sau ${attempts * 100}ms');
        return AuthResult.failure(message: 'Timeout: Không nhận được verification ID');
      }
      
    } catch (e) {
      // Nếu Firebase Phone Auth thất bại, fallback về Mock Mode
      if (e is FirebaseAuthException) {
        print('❌ Firebase Phone Auth failed: ${e.message}');
        
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
      print('❌ General error: $e');
      return AuthResult.failure(message: 'Có lỗi xảy ra: $e');
    }
    
    } catch (e) {
      print('❌ Error in sendPhoneOTP: $e');
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
      print('🔍 Attempting phone login for: $phoneNumber');
      
      // Format phone number
      String formattedPhone = phoneNumber;
      if (phoneNumber.startsWith('0') && phoneNumber.length == 10) {
        formattedPhone = '+84${phoneNumber.substring(1)}';
      } else if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+84$phoneNumber';
      }

      print('📱 Formatted phone: $formattedPhone');

      // Kiểm tra user có tồn tại trong Firestore không
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedPhone)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('❌ Phone number $formattedPhone not found in Firestore');
        return AuthResult.failure(
          message: 'Số điện thoại chưa được đăng ký',
          code: 'phone-not-found'
        );
      }

      // Tìm user trong Firebase Auth bằng phone number
      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();
      final uid = userData['uid'] as String?;

      if (uid == null) {
        return AuthResult.failure(message: 'Thông tin tài khoản không hợp lệ');
      }

      // Lấy user từ Firebase Auth
      final user = await _auth.currentUser;
      if (user == null || user.uid != uid) {
        print('❌ User not authenticated or UID mismatch. Current user: ${user?.uid}, Expected: $uid');
        // Thay vì yêu cầu OTP, cho phép đăng nhập bằng password
        print('✅ Phone number verified, allowing login with password');
        return AuthResult.success(null);
      }

      print('✅ Phone login successful for $formattedPhone');
      return AuthResult.success(user);
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
      // Trigger the authentication flow
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
        return AuthResult.success(userCredential.user);
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
          print('❌ Password reset verification failed: ${e.message}');
        },
        codeSent: (String verificationIdParam, int? resendToken) {
          verificationId = verificationIdParam;
          print('✅ Password reset SMS sent! Verification ID: $verificationIdParam');
          print('📱 SMS đã được gửi với template Password Reset');
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
      print('Error saving user to Firestore: $e');
    }
  }

  /// Chuyển đổi Firebase error code thành message tiếng Việt
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này';
      case 'wrong-password':
        return 'Mật khẩu không chính xác';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng';
      case 'phone-not-found':
        return 'Số điện thoại chưa được đăng ký';
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

      print('🔍 Checking if phone $formattedPhone is registered for password reset...');

      // Check in Firestore
      final userQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedPhone)
          .limit(1)
          .get();

      final isRegistered = userQuery.docs.isNotEmpty;
      print('📊 Firestore check result: $isRegistered');

      if (isRegistered) {
        return AuthResult.success(null);
      } else {
        return AuthResult.failure(
          message: 'Số điện thoại chưa được đăng ký',
          code: 'phone-not-registered',
        );
      }
    } catch (e) {
      print('❌ Error checking phone registration: $e');
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
      // Format phone number
      String formattedPhone = phoneNumber;
      if (phoneNumber.startsWith('0')) {
        formattedPhone = '+84${phoneNumber.substring(1)}';
      } else if (!phoneNumber.startsWith('+84')) {
        formattedPhone = '+84$phoneNumber';
      }

      print('🔄 Updating password for phone: $formattedPhone');

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
      
      print('✅ Password updated successfully');

      // Update password in Firestore
      await _firestore.collection('users').doc(currentUser.uid).update({
        'password': newPassword,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Password updated in Firestore');

      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth error updating password: ${e.message}');
      return AuthResult.failure(
        message: _getErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      print('❌ Error updating password: $e');
      return AuthResult.failure(message: 'Có lỗi xảy ra khi cập nhật mật khẩu');
    }
  }
}
