import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HistoryTabNavigation extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabChanged;

  const HistoryTabNavigation({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280.w,
      height: 50.h,
      child: Stack(
        children: [
            // Background tab container
            Positioned(
              left: -5.w,
              top: 2.h,
              child: Container(
                width: 290.w,
                height: 50.h,
                decoration: ShapeDecoration(
                  color: const Color(0xFFE5FFD5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            // Active tab indicator
            Positioned(
              left: selectedTab == 0 ? 0 : 90.w,
              top: 7.h,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                width: selectedTab == 0 ? 90.w : 180.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF3AAF3D),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3AAF3D).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ).animate()
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 200.ms,
                  curve: Curves.easeOutBack,
                ),
            ),
            // Lịch sử tab
            Positioned(
              left: 20.w,
              top: 16.h,
              child: GestureDetector(
                onTap: () => onTabChanged(0),
                child: Container(
                  width: 70.w,
                  height: 22.h,
                  alignment: Alignment.center,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      color: selectedTab == 0 ? Colors.white : Colors.black,
                      fontSize: 16.sp,
                      fontFamily: 'Urbanist',
                      fontWeight: selectedTab == 0 ? FontWeight.w600 : FontWeight.w500,
                      height: 1.25,
                      letterSpacing: 0.32,
                    ),
                    child: Text(
                      'Lịch sử',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            // Bộ sưu tầm tab
            Positioned(
              left: 116.w,
              top: 16.h,
              child: GestureDetector(
                onTap: () => onTabChanged(1),
                child: Container(
                  width: 180.w,
                  height: 22.h,
                  alignment: Alignment.center,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      color: selectedTab == 1 ? Colors.white : Colors.black,
                      fontSize: 16.sp,
                      fontFamily: 'Urbanist',
                      fontWeight: selectedTab == 1 ? FontWeight.w600 : FontWeight.w500,
                      height: 1.25,
                      letterSpacing: 0.32,
                    ),
                    child: Text(
                      'Bộ sưu tầm lá thuốc',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
