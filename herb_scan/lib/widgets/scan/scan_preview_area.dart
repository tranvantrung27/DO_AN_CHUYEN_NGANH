import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import '../../constants/app_colors.dart';
import 'scan_tips_card.dart';
import 'scan_loading_content.dart';

/// Enum cho các giai đoạn loading
enum ScanLoadingStage {
  none, // Không loading
  analyzing, // AI đang phân tích
  identifying, // Đang nhận dạng
}

/// Widget hiển thị preview area cho scan screen
class ScanPreviewArea extends StatelessWidget {
  final ScanLoadingStage loadingStage;
  final String? previewImagePath;

  const ScanPreviewArea({
    super.key,
    this.loadingStage = ScanLoadingStage.none,
    this.previewImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppColors.primaryGreen.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (loadingStage != ScanLoadingStage.none) {
      return _buildLoadingState();
    } else if (previewImagePath != null) {
      return _buildImagePreview();
    } else {
      return _buildEmptyState();
    }
  }

  Widget _buildLoadingState() {
    return Stack(
      children: [
        // Hiển thị ảnh nếu có
        if (previewImagePath != null)
          Image.file(
            File(previewImagePath!),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          )
        else
          // Background với gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppColors.primaryGreen.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
        // Overlay tối để text dễ đọc
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
        // Loading content
        Center(
          child: _buildLoadingContent(),
        ),
      ],
    );
  }

  Widget _buildLoadingContent() {
    switch (loadingStage) {
      case ScanLoadingStage.analyzing:
        return ScanLoadingContent(
          title: 'AI đang phân tích',
          subtitle: 'Quá trình có thể mất vài giây\nvui lòng giữ ứng dụng mở',
        );
      case ScanLoadingStage.identifying:
        return ScanLoadingContent(
          title: 'Đang nhận dạng',
          subtitle: 'Đang xử lý hình ảnh...',
        );
      case ScanLoadingStage.none:
        return const SizedBox.shrink();
    }
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        Image.file(
          File(previewImagePath!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        // Overlay gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.3),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated camera icon
        Icon(
          Icons.camera_alt_outlined,
          size: 100.sp,
          color: AppColors.primaryGreen,
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.1, 1.1),
              duration: 2000.ms,
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              begin: const Offset(1.1, 1.1),
              end: const Offset(1.0, 1.0),
              duration: 2000.ms,
              curve: Curves.easeInOut,
            ),
        SizedBox(height: 24.h),
        Text(
          'Chụp ảnh lá cây',
          style: TextStyle(
            fontSize: 18.sp,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideY(begin: 0.2, end: 0),
        SizedBox(height: 8.h),
        Text(
          'hoặc chọn từ thư viện',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 400.ms)
            .slideY(begin: 0.2, end: 0),
        SizedBox(height: 32.h),
        // Tips section
        const ScanTipsCard()
            .animate()
            .fadeIn(duration: 600.ms, delay: 600.ms)
            .slideY(begin: 0.2, end: 0),
      ],
    );
  }
}

