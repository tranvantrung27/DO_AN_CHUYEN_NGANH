import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_colors.dart';
import '../../mixins/validation_mixin.dart';
import '../../mixins/loading_mixin.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with ValidationMixin, LoadingMixin {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _newPasswordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  
  final _authService = AuthService();
  
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Manual validation
    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập mật khẩu mới'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mật khẩu phải có ít nhất 6 ký tự'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng xác nhận mật khẩu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mật khẩu xác nhận không khớp'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await withLoadingAndErrorHandling(
      () async {
        final result = await _authService.updatePassword(
          phoneNumber: widget.phoneNumber,
          verificationId: widget.verificationId,
          otp: widget.otp, // Sử dụng OTP thực tế từ màn hình trước
          newPassword: newPassword,
        );

        if (result.isSuccess) {
          // Đăng xuất user vì đã hoàn tất reset password
          await _authService.signOut();
          
          // Hiển thị thông báo thành công
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đặt lại mật khẩu thành công!'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Chờ một chút để user thấy thông báo
            await Future.delayed(const Duration(milliseconds: 500));
            
            // Navigate back to login screen
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          }
        } else {
          throw Exception(result.errorMessage);
        }
      },
      loadingMessage: 'Đang đặt lại mật khẩu...',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: SvgPicture.asset(
                      'assets/icons/comback.svg',
                      width: 24.w,
                      height: 24.h,
                      colorFilter: ColorFilter.mode(
                        const Color(0xFF4E4B66),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 13.h),
                
                // Title
                Text(
                  'Đặt lại mật khẩu',
                  style: TextStyle(
                    color: const Color(0xFF4E4B66),
                    fontSize: 32.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                    letterSpacing: 0.12,
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // New Password Field
                _buildPasswordField(
                  label: 'Nhập mật khẩu mới',
                  controller: _newPasswordController,
                  focusNode: _newPasswordFocusNode,
                  isVisible: _isNewPasswordVisible,
                  onToggleVisibility: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) return null; // Không hiển thị lỗi khi chưa nhập
                    if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                    return null;
                  },
                ),
                
                SizedBox(height: 16.h),
                
                // Confirm Password Field
                _buildPasswordField(
                  label: 'Nhập lại mật khẩu mới',
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  isVisible: _isConfirmPasswordVisible,
                  onToggleVisibility: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) return null; // Không hiển thị lỗi khi chưa nhập
                    if (value != _newPasswordController.text) return 'Mật khẩu xác nhận không khớp';
                    return null;
                  },
                ),
                
                SizedBox(height: 32.h),
                
                // Reset Password Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Đặt lại mật khẩu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with asterisk
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: label,
                style: TextStyle(
                  color: const Color(0xFF4E4B66),
                  fontSize: 14.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                  letterSpacing: 0.12,
                ),
              ),
              TextSpan(
                text: '*',
                style: TextStyle(
                  color: const Color(0xFFC20052),
                  fontSize: 14.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                  letterSpacing: 0.12,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 4.h),
        
        // Password Input Field
        SizedBox(
          height: 48.h,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: !isVisible,
            validator: validator,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15.sp,
              color: const Color(0xFF2D2D2D),
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: label == 'Nhập mật khẩu mới' ? 'Nhập mật khẩu mới' : 'Nhập lại mật khẩu mới',
              hintStyle: TextStyle(
                fontSize: 15.sp,
                color: const Color(0xFF9CA3AF),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: BorderSide(
                  color: const Color(0xFFE5E7EB), 
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: BorderSide(
                  color: const Color(0xFF3AAF3D), 
                  width: 1.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: BorderSide(
                  color: Colors.red, 
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: BorderSide(
                  color: Colors.red, 
                  width: 1.0,
                ),
              ),
              suffixIcon: GestureDetector(
                onTap: onToggleVisibility,
                child: Container(
                  width: 24.w,
                  height: 24.h,
                  padding: EdgeInsets.all(12.w),
                  child: Icon(
                    isVisible ? Icons.visibility_off : Icons.visibility,
                    size: 20.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}