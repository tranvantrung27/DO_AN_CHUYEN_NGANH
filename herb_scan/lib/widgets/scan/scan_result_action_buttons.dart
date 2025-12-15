import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

/// Widget chứa các nút action cho scan result screen
class ScanResultActionButtons extends StatelessWidget {
  final bool isSaving;
  final bool showViewDetails;
  final VoidCallback? onViewDetails;
  final VoidCallback onSave;

  const ScanResultActionButtons({
    super.key,
    required this.isSaving,
    required this.showViewDetails,
    this.onViewDetails,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showViewDetails)
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: isSaving ? null : onViewDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Xem chi tiết',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: OutlinedButton(
            onPressed: isSaving ? null : onSave,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              side: BorderSide(
                color: AppColors.primaryGreen,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: isSaving
                ? SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGreen,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_outlined, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Lưu vào lịch sử',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

