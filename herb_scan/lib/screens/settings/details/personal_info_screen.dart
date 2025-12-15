import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../../../services/index.dart';
import '../../../../constants/app_colors.dart';
import '../../../../widgets/common/app_input_field.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isEditMode = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isLoading = true;
  String? _selectedImagePath; // Ảnh đã chọn từ thư viện
  bool _isUploadingImage = false; // Trạng thái đang upload

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    setState(() => _isLoading = true);
    
    debugPrint('=== DEBUG: _initializeControllers START ===');
    
    final user = _authService.currentUser;
    debugPrint('DEBUG: currentUser is null? ${user == null}');
    
    // Lấy UID - ưu tiên từ Firebase Auth, nếu không có thì lấy từ SharedPreferences
    String? userId = user?.uid;
    
    if (userId == null) {
      debugPrint('DEBUG: User is null, trying to get UID from SharedPreferences...');
      try {
        final prefs = await SharedPreferences.getInstance();
        userId = prefs.getString('current_user_id');
        debugPrint('DEBUG: UID from SharedPreferences: $userId');
      } catch (e) {
        debugPrint('DEBUG: Error getting UID from SharedPreferences: $e');
      }
    }
    
    if (userId == null) {
      debugPrint('DEBUG: No UID found, initializing empty controllers');
      _nameController = TextEditingController(text: '');
      _emailController = TextEditingController(text: '');
      _phoneController = TextEditingController(text: '');
      setState(() => _isLoading = false);
      return;
    }

    debugPrint('DEBUG: Using UID: $userId');
    if (user != null) {
      debugPrint('DEBUG: User email (from Auth): ${user.email}');
      debugPrint('DEBUG: User phoneNumber (from Auth): ${user.phoneNumber}');
      debugPrint('DEBUG: User displayName (from Auth): ${user.displayName}');
    }

    // Khởi tạo với giá trị mặc định
    String? email;
    String? phoneNumber;
    String displayName = '';

    try {
      debugPrint('DEBUG: Fetching from Firestore with UID: $userId');
      // Luôn lấy từ Firestore trước (quan trọng cho user đăng ký bằng số điện thoại)
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      debugPrint('DEBUG: Firestore document exists? ${userDoc.exists}');
      
      if (userDoc.exists) {
        final userData = userDoc.data();
        debugPrint('DEBUG: Firestore userData: $userData');
        
        if (userData != null) {
          // Lấy phoneNumber từ Firestore (quan trọng vì Firebase Auth có thể không có)
          phoneNumber = userData['phoneNumber']?.toString();
          debugPrint('DEBUG: phoneNumber from Firestore: $phoneNumber');
          
          // Lấy email từ Firestore
          email = userData['email']?.toString();
          debugPrint('DEBUG: email from Firestore: $email');
          
          // Lấy displayName từ Firestore
          displayName = userData['displayName']?.toString() ?? '';
          debugPrint('DEBUG: displayName from Firestore: $displayName');
        } else {
          debugPrint('DEBUG: userData is null!');
        }
      } else {
        debugPrint('DEBUG: Firestore document does NOT exist for UID: $userId');
      }
      
      // Nếu Firestore không có, mới lấy từ Firebase Auth (nếu có)
      debugPrint('DEBUG: Checking fallback to Auth...');
      if (user != null) {
        if (phoneNumber == null || phoneNumber.isEmpty) {
          phoneNumber = user.phoneNumber;
          debugPrint('DEBUG: Using phoneNumber from Auth: $phoneNumber');
        }
        if (email == null || email.isEmpty) {
          email = user.email;
          debugPrint('DEBUG: Using email from Auth: $email');
        }
        if (displayName.isEmpty) {
          displayName = user.displayName ?? '';
          debugPrint('DEBUG: Using displayName from Auth: $displayName');
        }
      }
      
      // Nếu displayName vẫn rỗng, thử lấy từ email hoặc phoneNumber
      if (displayName.isEmpty) {
        if (email != null && email.isNotEmpty) {
          displayName = email.split('@')[0];
          debugPrint('DEBUG: Using displayName from email: $displayName');
        } else if (phoneNumber != null && phoneNumber.isNotEmpty) {
          displayName = phoneNumber;
          debugPrint('DEBUG: Using displayName from phoneNumber: $displayName');
        }
      }
      
      // Debug log tổng hợp
      debugPrint('=== DEBUG: Final loaded user data ===');
      debugPrint('DEBUG: Final phoneNumber: $phoneNumber');
      debugPrint('DEBUG: Final email: $email');
      debugPrint('DEBUG: Final displayName: $displayName');
    } catch (e, stackTrace) {
      // Nếu lỗi, dùng thông tin từ Auth (nếu có)
      debugPrint('DEBUG: ERROR loading user data: $e');
      debugPrint('DEBUG: StackTrace: $stackTrace');
      if (user != null) {
        email = user.email;
        phoneNumber = user.phoneNumber;
        displayName = user.displayName ?? user.email?.split('@')[0] ?? '';
        debugPrint('DEBUG: Using fallback values from Auth');
        debugPrint('DEBUG: Fallback phoneNumber: $phoneNumber');
        debugPrint('DEBUG: Fallback email: $email');
        debugPrint('DEBUG: Fallback displayName: $displayName');
      }
    }

    debugPrint('DEBUG: Setting controllers...');
    _nameController = TextEditingController(text: displayName);
    _emailController = TextEditingController(text: email ?? '');
    _phoneController = TextEditingController(text: phoneNumber ?? '');
    
    debugPrint('DEBUG: _nameController.text: ${_nameController.text}');
    debugPrint('DEBUG: _emailController.text: ${_emailController.text}');
    debugPrint('DEBUG: _phoneController.text: ${_phoneController.text}');
    debugPrint('=== DEBUG: _initializeControllers END ===');
    
    setState(() => _isLoading = false);
  }

  Future<String?> _getUserId() async {
    // Ưu tiên lấy từ Firebase Auth
    final user = _authService.currentUser;
    if (user != null) {
      return user.uid;
    }
    
    // Nếu không có, lấy từ SharedPreferences (cho trường hợp đăng nhập bằng phone + password)
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('current_user_id');
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = true;
    });
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
        
        // Tự động upload ảnh khi chọn
        await _uploadImageToFirebase(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _uploadImageToFirebase(String imagePath) async {
    final userId = await _getUserId();
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không tìm thấy thông tin người dùng'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      // Kiểm tra file có tồn tại không
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('File không tồn tại: $imagePath');
      }

      // Kiểm tra kích thước file (max 5MB)
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('File quá lớn. Vui lòng chọn file nhỏ hơn 5MB');
      }

      debugPrint('DEBUG: Bắt đầu upload ảnh cho user: $userId');
      debugPrint('DEBUG: File path: $imagePath');
      debugPrint('DEBUG: File size: ${fileSize / 1024} KB');

      // Tạo reference trong Firebase Storage với timestamp để tránh trùng lặp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_$timestamp.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_avatars')
          .child(fileName);

      debugPrint('DEBUG: Storage path: user_avatars/$fileName');

      // Upload file với metadata
      final uploadTask = storageRef.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=31536000',
        ),
      );

      // Theo dõi tiến trình upload
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        debugPrint('DEBUG: Upload progress: ${progress.toStringAsFixed(2)}%');
      });

      // Đợi upload hoàn tất
      final snapshot = await uploadTask;
      
      debugPrint('DEBUG: Upload state: ${snapshot.state}');
      debugPrint('DEBUG: Bytes transferred: ${snapshot.bytesTransferred}');
      debugPrint('DEBUG: Total bytes: ${snapshot.totalBytes}');
      
      // Kiểm tra xem upload có thành công không
      if (snapshot.state == TaskState.success) {
        debugPrint('DEBUG: Upload thành công, đang lấy download URL...');
        
        // Lấy download URL sau khi upload thành công
        final downloadURL = await snapshot.ref.getDownloadURL();
        debugPrint('DEBUG: Download URL: $downloadURL');

        // Cập nhật photoURL trong Firebase Auth
        final user = _authService.currentUser;
        if (user != null) {
          try {
            await user.updatePhotoURL(downloadURL);
            await user.reload();
          } catch (e) {
            debugPrint('Không thể cập nhật photoURL trong Auth: $e');
          }
        }

        // Cập nhật photoURL trong Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'photoURL': downloadURL,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        setState(() {
          _isUploadingImage = false;
          _selectedImagePath = null; // Reset sau khi upload thành công
        });

        // Reload lại user data để cập nhật UI
        await _initializeControllers();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã cập nhật ảnh đại diện thành công'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        }
      } else if (snapshot.state == TaskState.error) {
        debugPrint('DEBUG: Upload error state');
        throw Exception('Upload thất bại. Vui lòng thử lại.');
      } else {
        throw Exception('Upload không thành công. State: ${snapshot.state}');
      }
    } catch (e, stackTrace) {
      debugPrint('DEBUG: Exception khi upload: $e');
      debugPrint('DEBUG: Stack trace: $stackTrace');
      
      setState(() {
        _isUploadingImage = false;
      });

      String errorMessage = 'Lỗi khi tải ảnh lên';
      
      // Xử lý các loại lỗi khác nhau
      final errorString = e.toString().toLowerCase();
      
      if (errorString.contains('object-not-found')) {
        errorMessage = 'Lỗi: Không tìm thấy file trên server. Vui lòng kiểm tra Firebase Storage rules.';
      } else if (errorString.contains('permission-denied') || errorString.contains('unauthorized')) {
        errorMessage = 'Lỗi: Không có quyền truy cập. Vui lòng kiểm tra Firebase Storage rules.';
      } else if (errorString.contains('network')) {
        errorMessage = 'Lỗi: Không có kết nối mạng. Vui lòng kiểm tra internet.';
      } else if (errorString.contains('quota') || errorString.contains('storage')) {
        errorMessage = 'Lỗi: Hết dung lượng lưu trữ. Vui lòng liên hệ hỗ trợ.';
      } else {
        errorMessage = 'Lỗi khi tải ảnh lên: ${e.toString()}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _handleSave() async {
    final userId = await _getUserId();
    if (userId == null) {
      // Nếu không có user ID, quay lại màn hình trước
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    final user = _authService.currentUser;

    try {
      final newName = _nameController.text.trim();
      final newEmail = _emailController.text.trim();
      final newPhone = _phoneController.text.trim();

      // Cập nhật displayName trong Firebase Auth (nếu có user và có thay đổi)
      if (user != null && newName.isNotEmpty && newName != user.displayName) {
        try {
          await user.updateDisplayName(newName);
        } catch (e) {
          debugPrint('Không thể cập nhật displayName trong Auth: $e');
        }
      }
      
      // Cập nhật email trong Firebase Auth (nếu có user và có thay đổi)
      if (user != null && newEmail.isNotEmpty && newEmail != user.email) {
        try {
          // verifyBeforeUpdateEmail sẽ gửi email xác thực trước khi update
          await user.verifyBeforeUpdateEmail(newEmail);
        } catch (e) {
          // Nếu không thể update email (có thể cần re-authenticate), chỉ cập nhật trong Firestore
          if (kDebugMode) {
            debugPrint('Không thể cập nhật email trong Auth: $e');
          }
        }
      }

      // Reload user để lấy thông tin mới nhất (nếu có)
      if (user != null) {
        await user.reload();
      }
      final updatedUser = _authService.currentUser;

      // Lấy giá trị hiện tại từ Firestore để giữ lại nếu trường rỗng
      final currentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final currentData = currentDoc.exists ? currentDoc.data() : null;

      // Cập nhật trong Firestore - lưu tất cả thông tin người dùng nhập
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'displayName': newName.isNotEmpty ? newName : (updatedUser?.displayName ?? currentData?['displayName'] ?? ''),
        'email': newEmail.isNotEmpty ? newEmail : (updatedUser?.email ?? currentData?['email'] ?? ''),
        'phoneNumber': newPhone.isNotEmpty ? newPhone : (updatedUser?.phoneNumber ?? currentData?['phoneNumber'] ?? ''),
        'photoURL': updatedUser?.photoURL ?? currentData?['photoURL'],
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Cập nhật lại controllers với giá trị mới
      await _initializeControllers();

      if (mounted) {
        setState(() {
          _isEditMode = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã lưu thông tin thành công'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }

      // Reload lại user để cập nhật UI
      await _initializeControllers();
      
      // Không quay lại màn hình trước, ở lại màn hình này
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu thông tin: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Thông tin cá nhân',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: -0.27,
          ),
        ),
        actions: [
          if (_isEditMode)
            TextButton(
              onPressed: _handleSave,
              child: Text(
                'Lưu',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 16.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.24,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _toggleEditMode,
              child: Text(
                'Chỉnh sửa',
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 16.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.24,
                ),
              ),
            ),
          SizedBox(width: 16.w),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    // Avatar section
                    _buildAvatarSection(user),
                    SizedBox(height: 20.h),
                    // Form fields
                    _buildFormFields(user),
              SizedBox(height: 20.h),
              // Change password section
              _buildChangePasswordSection(),
                    SizedBox(height: 20.h),
                    // Delete account button
                    _buildLogoutButton(),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAvatarSection(user) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 128.w,
                    height: 128.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: _selectedImagePath != null
                          ? DecorationImage(
                              image: FileImage(File(_selectedImagePath!)),
                              fit: BoxFit.cover,
                            )
                          : (user?.photoURL != null
                              ? DecorationImage(
                                  image: NetworkImage(user!.photoURL!),
                                  fit: BoxFit.cover,
                                )
                              : null),
                      color: (_selectedImagePath == null && user?.photoURL == null)
                          ? Colors.grey[300]
                          : null,
                    ),
                    child: (_selectedImagePath == null && user?.photoURL == null)
                        ? Icon(
                            Icons.person,
                            size: 64.sp,
                            color: Colors.grey[600],
                          )
                        : (_isUploadingImage
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryGreen,
                                ),
                              )
                            : null),
                  ),
                  // Edit button on avatar
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _isUploadingImage ? null : _pickImageFromGallery,
                      child: Container(
                        width: 39.30.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 2,
                            color: AppColors.backgroundCream,
                          ),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              Text(
                user?.displayName ?? user?.email?.split('@')[0] ?? 'Người dùng',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  letterSpacing: -0.33,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                user?.email ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(user) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Họ và tên
          AppInputField(
            label: 'Họ và tên',
            controller: _nameController,
            icon: Icons.person_outline,
            enabled: _isEditMode,
          ),
          SizedBox(height: 20.h),
          // Email
          AppInputField(
            label: 'Email',
            controller: _emailController,
            icon: Icons.email_outlined,
            enabled: _isEditMode,
            hintText: _emailController.text.isEmpty ? 'email@example.com' : null,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 20.h),
          // Số điện thoại
          AppInputField(
            label: 'Số điện thoại',
            controller: _phoneController,
            icon: Icons.phone_outlined,
            enabled: _isEditMode,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          width: 1,
          color: Colors.transparent,
        ),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to change password screen
        },
        borderRadius: BorderRadius.circular(8.r),
        child: Row(
          children: [
            Icon(
              Icons.lock_outline,
              color: AppColors.warning,
              size: 24.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                'Đổi mật khẩu',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      child: ElevatedButton(
        onPressed: () => _showDeleteAccountDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'Xóa tài khoản',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.error,
            fontSize: 16.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.50,
            letterSpacing: 0.24,
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Xóa tài khoản',
            style: TextStyle(
              fontSize: 18.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa tài khoản? Hành động này không thể hoàn tác.',
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // TODO: Implement delete account functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Chức năng xóa tài khoản đang được phát triển'),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              child: Text(
                'Xóa',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 16.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

