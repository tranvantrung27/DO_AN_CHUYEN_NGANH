import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

/// Widget tái sử dụng cho Switch Tile với icon trong khung tròn màu và title
/// 
/// Ví dụ sử dụng:
/// ```dart
/// CustomSwitchTile(
///   icon: Icons.bell,
///   title: 'Thông báo',
///   iconColor: AppColors.info,
///   value: _notifications,
///   onChanged: (value) {
///     setState(() => _notifications = value);
///   },
/// )
/// ```
class CustomSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final EdgeInsets? padding;

  const CustomSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon trong khung tròn màu
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20.sp,
              color: iconColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 16.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor ?? AppColors.primaryGreen,
            activeTrackColor: (activeColor ?? AppColors.primaryGreen).withValues(alpha: 0.5),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade300,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            splashRadius: 20.0,
          ),
        ],
      ),
    );
  }
}
