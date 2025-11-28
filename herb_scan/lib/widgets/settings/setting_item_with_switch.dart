import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_switch.dart';

/// Widget hiển thị một item cài đặt có switch
class SettingItemWithSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged; // Nullable để có thể disable

  const SettingItemWithSwitch({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.onChanged, // Optional - nếu null thì switch bị disable
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? 
                      (theme.brightness == Brightness.dark 
                          ? Colors.white 
                          : const Color(0xFF333333));
    
    return Padding(
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
          CustomSwitch(
            value: value,
            onChanged: onChanged, // Nếu null thì switch sẽ không hoạt động
          ),
        ],
      ),
    );
  }
}

