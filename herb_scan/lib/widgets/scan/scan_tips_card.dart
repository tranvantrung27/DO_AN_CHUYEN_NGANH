import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

/// Widget hiển thị tips cho scan
class ScanTipsCard extends StatelessWidget {
  const ScanTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 20.sp,
                color: AppColors.primaryGreen,
              ),
              SizedBox(width: 8.w),
              Text(
                'Mẹo chụp ảnh tốt',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildTipItem('Đảm bảo đủ ánh sáng'),
          SizedBox(height: 6.h),
          _buildTipItem('Chụp rõ nét, không bị mờ'),
          SizedBox(height: 6.h),
          _buildTipItem('Đặt lá cây ở giữa khung hình'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Row(
      children: [
        Container(
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

