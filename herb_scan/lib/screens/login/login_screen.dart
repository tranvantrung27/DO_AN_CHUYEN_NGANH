import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/index.dart';
import '../../widgets/index.dart';
import '../../widgets/common/social_login_button.dart';
import '../../mixins/index.dart';
import '../../services/index.dart';
import '../../models/index.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../main_navigation_screen.dart';

/// Màn hình đăng nhập
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
    with LoadingMixin, ValidationMixin {
  
  final AuthService _authService = AuthService();
  bool _rememberPassword = false;

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

            // Login Button
            _buildLoginButton(),

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
      title: 'Chào mừng trở lại 🌿',
      subtitle: 'Hãy tiếp tục khám phá thế giới thảo\ndược cùng chúng tôi',
    );
  }

  Widget _buildForm() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 400.w),
      child: Column(
        children: [
          // Login fields using new widget
          LoginFields(
            usernameController: getController('username'),
            passwordController: getController('password'),
            onUsernameChanged: (value) => _validateUsername(value),
            onPasswordChanged: (value) => validatePassword('password', value),
            hasUsernameError: hasError('username'),
            hasPasswordError: hasError('password'),
          ),
          
          SizedBox(height: 18.h),
          
          // Remember password & Forgot password
          _buildRememberAndForgot(),
        ],
      ),
    );
  }


  Widget _buildRememberAndForgot() {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Remember password
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _rememberPassword = !_rememberPassword;
                  });
                },
                child: Container(
                  width: 24.r,
                  height: 24.r,
                  decoration: ShapeDecoration(
                    color: _rememberPassword 
                        ? const Color(0xFF1877F2) 
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.r),
                      side: BorderSide(
                        color: _rememberPassword 
                            ? const Color(0xFF1877F2)
                            : const Color(0xFF4E4B66),
                        width: 1,
                      ),
                    ),
                  ),
                  child: _rememberPassword
                      ? Icon(
                          Icons.check,
                          size: 16.r,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                'Nhớ mật khẩu',
                style: TextStyle(
                  color: const Color(0xFF4E4B66),
                  fontSize: 14.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                  letterSpacing: 0.12,
                ),
              ),
            ],
          ),
          
          // Forgot password
          TextButton(
            onPressed: _handleForgotPassword,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Quên mật khẩu ?',
              style: TextStyle(
                color: const Color(0xFF5890FF),
                fontSize: 14.sp,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 1.50,
                letterSpacing: 0.12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return AuthButton(
      text: 'Đăng nhập',
      onPressed: _handleLogin,
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
      questionText: 'Bạn không có tài khoản? ',
      actionText: 'Đăng ký',
      onAction: _navigateToRegister,
    );
  }

  // Helper methods
  bool _validateUsername(String value) {
    if (_isEmail(value)) {
      return validateEmail('username', value);
    } else if (_isPhone(value)) {
      return validatePhone('username', value);
    } else {
      validateField('username', value, customValidator: (value) => 'Vui lòng nhập email hoặc số điện thoại hợp lệ');
      return false;
    }
  }

  bool _isEmail(String value) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value);
  }

  bool _isPhone(String value) {
    // Remove all non-digit characters
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    // Check if it's a valid Vietnamese phone number
    return (digitsOnly.startsWith('0') && digitsOnly.length == 10) ||
           (digitsOnly.startsWith('84') && digitsOnly.length == 11) ||
           (digitsOnly.startsWith('+84') && digitsOnly.length == 12);
  }

  String _formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Add +84 prefix if it's a Vietnamese number
    if (digitsOnly.startsWith('0') && digitsOnly.length == 10) {
      return '+84${digitsOnly.substring(1)}';
    } else if (digitsOnly.startsWith('84') && digitsOnly.length == 11) {
      return '+$digitsOnly';
    } else if (digitsOnly.startsWith('+84') && digitsOnly.length == 12) {
      return digitsOnly;
    }
    
    return phoneNumber; // Return original if can't format
  }

  // Event handlers
  void _handleLogin() async {
    // Validate form
    final username = getController('username').text;
    final password = getController('password').text;
    
    if (!_validateUsername(username) || 
        !validatePassword('password', password)) {
      return;
    }

    await withLoadingAndErrorHandling(() async {
      AuthResult result;
      
      if (_isEmail(username)) {
        // Đăng nhập bằng email
        result = await _authService.signInWithEmailPassword(
          email: username,
          password: password,
        );
      } else {
        // Đăng nhập bằng số điện thoại
        final formattedPhone = _formatPhoneNumber(username);
        result = await _authService.signInWithPhonePassword(
          phoneNumber: formattedPhone,
          password: password,
        );
      }
      
      if (result.isSuccess && mounted) {
        // Đăng nhập thành công, chuyển đến màn hình chính
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      } else if (result.errorMessage != null) {
        print('🔍 Login error: ${result.errorMessage}');
        throw Exception(result.errorMessage);
      } else {
        print('🔍 Login failed but no error message provided');
        throw Exception('Đăng nhập thất bại');
      }
    }, 
    loadingMessage: 'Đang đăng nhập...',
    errorMessage: 'Đăng nhập thất bại',
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

  void _handleAppleLogin() async {
    // TODO: Implement Apple login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Apple login chưa tích hợp')),
    );
  }

  void _handleFacebookLogin() async {
    // TODO: Implement Facebook login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Facebook login chưa tích hợp')),
    );
  }

  void _handleForgotPassword() async {
    print('🔍 Forgot password button tapped');
    // Navigate to forgot password screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }
}
