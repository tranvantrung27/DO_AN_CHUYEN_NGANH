import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget hiển thị một item cài đặt với icon, title và onTap
class SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? 
                      (theme.brightness == Brightness.dark 
                          ? Colors.white 
                          : const Color(0xFF333333));
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 24.w,
                  height: 24.w,
                  child: Icon(
                    icon,
                    size: 24.sp,
                    color: textColor,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17.sp,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.17,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.chevron_right,
              size: 24.sp,
              color: textColor,
            ),
          ],
        ),
      ),
    );
  }
}

