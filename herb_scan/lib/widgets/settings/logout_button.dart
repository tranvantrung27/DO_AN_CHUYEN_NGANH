import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

/// Widget nút đăng xuất với màu đỏ nhạt
class LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const LogoutButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1), // Màu đỏ nhạt
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              size: 20.sp,
              color: AppColors.error,
            ),
            SizedBox(width: 8.w),
            Text(
              'Đăng xuất',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 16.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
