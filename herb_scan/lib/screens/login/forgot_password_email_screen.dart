import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/index.dart';
import '../../widgets/index.dart';

class ForgotPasswordEmailScreen extends StatefulWidget {
  const ForgotPasswordEmailScreen({super.key});

  @override
  State<ForgotPasswordEmailScreen> createState() => _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends State<ForgotPasswordEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

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
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 24.w,
                        height: 24.h,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
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
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
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
                          'Đừng lo lắng! Điều đó vẫn xảy ra.\nVui lòng nhập địa chỉ liên kết với tài khoản\ncủa bạn.',
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
                    
                    // Email Input Section
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nhập địa chỉ Email của bạn:',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                              letterSpacing: 0.12,
                            ),
                          ),
                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 10.h),
                    
                    // Email Input Field
                    TextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15.sp,
                        color: const Color(0xFF2D2D2D),
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: 'herbscan@youremail.com',
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
                      ),
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

  void _handleContinue() {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập địa chỉ email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập địa chỉ email hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    

    print('Reset password for email: $email');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã gửi email đặt lại mật khẩu đến $email'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
    
    // Navigate back to login
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
