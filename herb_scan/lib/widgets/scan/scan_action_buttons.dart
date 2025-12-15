import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_colors.dart';

/// Widget chứa các nút action cho scan screen
class ScanActionButtons extends StatelessWidget {
  final bool isScanning;
  final VoidCallback onGalleryTap;
  final VoidCallback onCaptureTap;

  const ScanActionButtons({
    super.key,
    required this.isScanning,
    required this.onGalleryTap,
    required this.onCaptureTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Gallery button
        Expanded(
          child: SizedBox(
            height: 56.h,
            child: OutlinedButton(
              onPressed: isScanning ? null : onGalleryTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: BorderSide(
                  color: AppColors.primaryGreen,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8.w),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library, size: 20.sp),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      'Thư viện',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 800.ms)
              .slideX(begin: -0.2, end: 0),
        ),
        SizedBox(width: 12.w),
        // Camera button
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 56.h,
            child: ElevatedButton(
              onPressed: isScanning ? null : onCaptureTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 4,
                shadowColor: AppColors.primaryGreen.withValues(alpha: 0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, size: 20.sp),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      'Chụp và quét',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 1000.ms)
              .slideX(begin: 0.2, end: 0)
              .shimmer(
                delay: 2000.ms,
                duration: 1500.ms,
                color: Colors.white.withValues(alpha: 0.3),
              ),
        ),
      ],
    );
  }
}

