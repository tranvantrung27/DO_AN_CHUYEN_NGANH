import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    // Tính toán kích thước và vị trí chính xác
    const double indicatorPadding = 5.0;
    
    // Kích thước tab "Lịch sử" - tính toán dựa trên text và padding
    final double tab1Width = 90.w;
    // Kích thước tab "Bộ sưu tầm lá thuốc"
    final double tab2Width = 180.w;
    
    // Vị trí và kích thước của indicator
    final double indicatorLeft = selectedTab == 0 
        ? indicatorPadding 
        : tab1Width + indicatorPadding;
    final double indicatorWidth = selectedTab == 0 ? tab1Width : tab2Width;
    
    return Container(
      width: 280.w,
      height: 50.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE5FFD5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          // Active tab indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            left: indicatorLeft,
            top: indicatorPadding,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              width: indicatorWidth,
              height: 50.h - (indicatorPadding * 2),
              decoration: BoxDecoration(
                color: const Color(0xFF3AAF3D),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3AAF3D).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          // Tab buttons - sử dụng Positioned để căn chỉnh chính xác
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            bottom: 0,
            child: Row(
              children: [
                // Lịch sử tab
                SizedBox(
                  width: tab1Width,
                  child: GestureDetector(
                    onTap: () => onTabChanged(0),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 50.h,
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
                        child: const Text(
                          'Lịch sử',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                // Bộ sưu tầm tab
                SizedBox(
                  width: tab2Width,
                  child: GestureDetector(
                    onTap: () => onTabChanged(1),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 50.h,
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
                        child: const Text(
                          'Bộ sưu tầm lá thuốc',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
