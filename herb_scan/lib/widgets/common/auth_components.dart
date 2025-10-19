import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Component chung cho các button đăng nhập/đăng ký
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 400.w),
      height: 52.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3AAF3D), Color(0xFF2E8B2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3AAF3D).withOpacity(0.3),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Component chung cho header của auth screens
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF1F2937),
              fontSize: 40.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            subtitle,
            style: TextStyle(
              color: const Color(0xFF6B7280),
              fontSize: 16.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 1.5,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Component chung cho divider text
class AuthDividerText extends StatelessWidget {
  const AuthDividerText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hoặc tiếp tục với',
      style: TextStyle(
        color: const Color(0xFF4E4B66),
        fontSize: 14.sp,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
        height: 1.2,
        letterSpacing: 0.12,
      ),
    );
  }
}

/// Component chung cho footer với link chuyển đổi
class AuthFooter extends StatelessWidget {
  final String questionText;
  final String actionText;
  final VoidCallback onAction;

  const AuthFooter({
    super.key,
    required this.questionText,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: questionText,
            style: TextStyle(
              color: const Color(0xFF4E4B66),
              fontSize: 14.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 1.2,
              letterSpacing: 0.12,
            ),
          ),
          WidgetSpan(
            child: GestureDetector(
              onTap: onAction,
              child: Text(
                actionText,
                style: TextStyle(
                  color: const Color(0xFF3AAF3D),
                  fontSize: 14.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: 0.12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
