import 'package:flutter/material.dart';
import '../constants/index.dart';
import 'common/animated_dot_indicator.dart';

class IntroNavigation extends StatelessWidget {
  final int currentIndex; // 0, 1, 2 cho 3 màn hình
  final VoidCallback? onBack; // Callback cho nút "Quay lại"
  final VoidCallback onNext; // Callback cho nút "Tiếp tục" hoặc "Bắt đầu"
  final String nextButtonText; // Text cho nút next

  const IntroNavigation({
    super.key,
    required this.currentIndex,
    this.onBack,
    required this.onNext,
    required this.nextButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 430,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Animated Dots indicator using reusable component
          AnimatedDotIndicator(
            itemCount: 3,
            currentIndex: currentIndex,
            activeColor: AppColors.primaryGreen,
            inactiveColor: const Color(0xFFA0A3BD),
            animationDuration: AppAnimations.normal,
            animationCurve: AppAnimations.easeInOut,
          ),
          // Navigation buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nút "Quay lại" (chỉ hiển thị từ màn hình 2 trở đi)
              if (onBack != null) ...[
                GestureDetector(
                  onTap: onBack,
                  child: Text(
                    'Quay lại',
                    style: AppTheme.buttonText.copyWith(
                      color: const Color(0xFFB0B3B8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              // Nút "Tiếp tục" hoặc "Bắt đầu"
              GestureDetector(
                onTap: onNext,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                  decoration: ShapeDecoration(
                    color: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    nextButtonText,
                    style: AppTheme.buttonText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
