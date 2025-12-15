import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

/// Widget header cho màn hình scan
class ScanHeader extends StatelessWidget {
  const ScanHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.camera_alt,
          size: 28.sp,
          color: AppColors.primaryGreen,
        ),
        SizedBox(width: 12.w),
        Text(
          'Quét lá cây',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
      ],
    );
  }
}

