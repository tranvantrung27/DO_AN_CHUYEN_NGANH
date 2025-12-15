import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/index.dart';
import '../../widgets/index.dart';
import '../../mixins/index.dart';
import '../../services/index.dart';
import '../../models/index.dart';
import '../main_navigation_screen.dart';
import 'otp_verification_screen.dart';

/// Màn hình đăng ký
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> 
    with LoadingMixin, ValidationMixin {
  
  final AuthService _authService = AuthService();
  bool _isEmailAuth = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: AppLoadingOverlay(
        isLoading: isLoading,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 24.w,
          vertical: 16.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            _buildHeader(),

            SizedBox(height: 24.h),

            // Form
            _buildForm(),

            SizedBox(height: 28.h),

            // Register Button
            _buildRegisterButton(),

            SizedBox(height: 32.h),

            // Divider text
            _buildDividerText(),

            SizedBox(height: 24.h),

            // Social Login Buttons
            _buildSocialButtons(),

            SizedBox(height: 24.h),

            // Footer
            _buildFooter(),
            
            SizedBox(height: 20.h), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AuthHeader(
      title: 'Xin chào bạn mới !',
      subtitle: 'Hãy tạo tài khoản để bắt đầu khám phá\nthảo dược cùng chúng tôi',
    );
  }

  Widget _buildForm() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 400.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Register fields using new widget
          RegisterFields(
            usernameController: getController('username'),
            passwordController: getController('password'),
            confirmPasswordController: getController('confirmPassword'),
            onUsernameChanged: (value) => _validateUsername(value),
            onPasswordChanged: (value) => validatePassword('password', value),
            onConfirmPasswordChanged: (value) => _validateConfirmPassword(value),
            onAuthTypeChanged: (isEmail) {
              setState(() {
                _isEmailAuth = isEmail;
                // Clear username field when switching
                getController('username').clear();
                clearError('username');
              });
            },
            hasUsernameError: hasError('username'),
            hasPasswordError: hasError('password'),
            hasConfirmPasswordError: hasError('confirmPassword'),
            isEmailAuth: _isEmailAuth,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return AuthButton(
      text: 'Đăng ký',
      onPressed: _handleRegister,
      isLoading: isLoading,
    );
  }

  Widget _buildDividerText() {
    return const AuthDividerText();
  }

  Widget _buildSocialButtons() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 400.w),
      child: Column(
        children: [
          // Google login
          SocialLoginButton.google(
            onPressed: _handleGoogleLogin,
          ),

          SizedBox(height: 12.h),

          // Apple login
          SocialLoginButton.apple(
            onPressed: _handleAppleLogin,
          ),

          SizedBox(height: 12.h),

          // Facebook login
          SocialLoginButton.facebook(
            onPressed: _handleFacebookLogin,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return AuthFooter(
      questionText: 'Đã có tài khoản? ',
      actionText: 'Đăng nhập',
      onAction: _navigateToLogin,
    );
  }

  // Helper methods
  String _formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    String digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Add +84 prefix if it's a Vietnamese number
    if (digitsOnly.startsWith('0') && digitsOnly.length == 10) {
      return '+84${digitsOnly.substring(1)}';
    } else if (digitsOnly.startsWith('84') && digitsOnly.length == 11) {
      return '+$digitsOnly';
    } else if (digitsOnly.startsWith('+84') && digitsOnly.length == 12) {
      return digitsOnly;
    }
    
    return phone; // Return original if can't format
  }

  void _showPhoneAlreadyRegisteredDialog(String phoneNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF3AAF3D),
                size: 24.r,
              ),
              SizedBox(width: 8.w),
              Text(
                'Số điện thoại đã được đăng ký',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Số điện thoại $phoneNumber đã được sử dụng để đăng ký tài khoản.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Bạn có thể:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '• Đăng nhập với số điện thoại này\n• Sử dụng số điện thoại khác để đăng ký',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Đóng',
                style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: 14.sp,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToLogin();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3AAF3D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
              child: Text(
                'Đăng nhập',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _validateUsername(String value) {
    if (_isEmailAuth) {
      return validateEmail('username', value);
    } else {
      return validatePhone('username', value);
    }
  }

  bool _validateConfirmPassword(String value) {
    final password = getController('password').text;
    return validateConfirmPassword('confirmPassword', value, password);
  }

  // Event handlers
  void _handleRegister() async {
    // Validate form
    final username = getController('username').text;
    final password = getController('password').text;
    final confirmPassword = getController('confirmPassword').text;
    
    if (!_validateUsername(username) || 
        !validatePassword('password', password) ||
        !_validateConfirmPassword(confirmPassword)) {
      return;
    }

    await withLoadingAndErrorHandling(() async {
      AuthResult result;
      
      if (_isEmailAuth) {
        // Đăng ký bằng email
        result = await _authService.registerWithEmailPassword(
          email: username,
          password: password,
          displayName: username.split('@')[0],
        );
      } else {
        // Đăng ký bằng số điện thoại
        final formattedPhone = _formatPhoneNumber(username);
        result = await _authService.sendPhoneOTP(formattedPhone);
        
        // Kiểm tra nếu số điện thoại đã được đăng ký
        if (!result.isSuccess && result.errorCode == 'phone-already-registered') {
          // Hiển thị dialog thông báo rõ ràng
          _showPhoneAlreadyRegisteredDialog(formattedPhone);
          return;
        }
        
        if (result.isSuccess && result.verificationId != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                phoneNumber: formattedPhone,
                verificationId: result.verificationId!,
              ),
            ),
          );
          return;
        }
      }
      
      if (result.isSuccess && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      } else if (result.errorMessage != null) {
        throw Exception(result.errorMessage);
      }
    }, 
    loadingMessage: 'Đang tạo tài khoản...',
    errorMessage: 'Đăng ký thất bại',
    );
  }

  void _handleGoogleLogin() async {
    await withLoadingAndErrorHandling(() async {
      final result = await _authService.signInWithGoogle();
      
      if (result.isSuccess && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      } else if (result.errorMessage != null) {
        throw Exception(result.errorMessage);
      }
    },
    loadingMessage: 'Đang đăng nhập với Google...',
    errorMessage: 'Đăng nhập Google thất bại',
    );
  }

  void _handleAppleLogin() {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Apple login chưa được hỗ trợ')),
    );
  }

  void _handleFacebookLogin() {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Facebook login chưa được hỗ trợ')),
    );
  }

  void _navigateToLogin() {
    Navigator.pop(context);
  }
}