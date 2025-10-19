import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/index.dart';
import '../../widgets/index.dart';
import 'forgot_password_email_screen.dart';
import 'forgot_password_sms_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _isEmailSelected = true;

  @override
  void initState() {
    super.initState();
    print('🔍 ForgotPasswordScreen initialized');
  }
  String _email = 'herbscan@youremail.com';
  String _phoneNumber = '+84-334-xxx-xxx';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: Column(
          children: [
            // Main Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 24.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/comback.svg',
                            width: 24.w,
                            height: 24.h,
                            colorFilter: ColorFilter.mode(
                              AppColors.textSecondary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Title and Description
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quên mật khẩu?',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 32.sp,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            height: 1.50,
                            letterSpacing: 0.12,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          'Đừng lo lắng! Điều đó vẫn xảy ra.\nVui lòng chọn email hoặc số điện thoại được liên kết với tài khoản của bạn.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16.sp,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                            letterSpacing: 0.12,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Email Option
                    _buildRecoveryOption(
                      icon: Icons.email_outlined,
                      title: 'Nhận mã qua Email:',
                      value: _email,
                      isSelected: _isEmailSelected,
                      onTap: () => setState(() => _isEmailSelected = true),
                    ),
                    
                    SizedBox(height: 10.h),
                    
                    // SMS Option
                    _buildRecoveryOption(
                      icon: Icons.sms_outlined,
                      title: 'Nhập mã qua SMS:',
                      value: _phoneNumber,
                      isSelected: !_isEmailSelected,
                      onTap: () => setState(() => _isEmailSelected = false),
                    ),
                  ],
                ),
              ),
            ),
            
            // Continue Button
            ContinueButton(
              text: 'Tiếp tục',
              onPressed: _handleContinue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryOption({
    required IconData icon,
    required String title,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF1F4),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(
                    icon,
                    size: 24.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: const Color(0xFF667080),
                        fontSize: 14.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                        letterSpacing: 0.12,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      value,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                        letterSpacing: 0.12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryGreen : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16.sp,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinue() {
    if (_isEmailSelected) {
      // Navigate to Email input screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ForgotPasswordEmailScreen(),
        ),
      );
    } else {
      // Navigate to SMS input screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ForgotPasswordSMSScreen(),
        ),
      );
    }
  }
}
