import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

/// Widget Input Field với Label + Icon
/// 
/// Hiệu ứng:
/// - Label màu xám đậm phía trên
/// - Input field trắng với shadow đẹp
/// - Icon bên trái màu xám nhạt
/// - Border radius 12px
/// - Có thể enable/disable
/// 
/// Ví dụ trong app:
/// - "Họ và tên" với icon user
/// - "Email" với icon mail
/// 
/// Cách dùng:
/// ```dart
/// AppInputField(
///   label: 'Họ và tên',
///   controller: _nameController,
///   icon: Icons.person,
///   enabled: true,
/// )
/// ```
class AppInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool enabled;
  final String? hintText;
  final TextInputType? keyboardType;

  const AppInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.enabled = true,
    this.hintText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
            height: 1.5,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            style: TextStyle(
              color: AppColors.textPrimaryDark,
              fontSize: 16.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: AppColors.textPlaceholder,
                fontSize: 16.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                icon,
                color: AppColors.textSecondary,
                size: 20.sp,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              filled: false,
            ),
          ),
        ),
      ],
    );
  }
}

