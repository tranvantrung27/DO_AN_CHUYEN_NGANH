import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

/// Widget hiển thị một item cài đặt với icon trong khung tròn màu, title và onTap
class SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor; // Màu nền của icon (mặc định là xanh dương)

  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconBgColor = iconColor ?? AppColors.info;
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Icon trong khung tròn màu
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: iconBgColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20.sp,
                    color: iconBgColor,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontSize: 16.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.chevron_right,
              size: 20.sp,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
