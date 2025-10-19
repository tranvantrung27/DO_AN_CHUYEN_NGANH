import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

/// Component chung cho button "Tiếp tục" trong Forgot Password flow
class ContinueButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ContinueButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundCream,
        boxShadow: [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 4,
            offset: Offset(0, -2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 13.h),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        child: GestureDetector(
          onTap: onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  height: 1.50,
                  letterSpacing: 0.12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
