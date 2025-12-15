import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'custom_switch_tile.dart';

/// Widget hiển thị một item cài đặt có switch với icon trong khung tròn màu
/// Sử dụng CustomSwitchTile bên trong
class SettingItemWithSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? iconColor; // Màu nền của icon

  const SettingItemWithSwitch({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.onChanged,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconBgColor = iconColor ?? AppColors.info;
    
    return CustomSwitchTile(
      icon: icon,
      title: title,
      iconColor: iconBgColor,
      value: value,
      onChanged: onChanged,
    );
  }
}
