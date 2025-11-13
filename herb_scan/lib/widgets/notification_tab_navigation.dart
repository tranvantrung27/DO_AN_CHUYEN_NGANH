import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationTabNavigation extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int>? onChanged;

  const NotificationTabNavigation({
    super.key,
    this.currentIndex = 0,
    this.onChanged,
  });

  @override
  State<NotificationTabNavigation> createState() => _NotificationTabNavigationState();
}

class _NotificationTabNavigationState extends State<NotificationTabNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant NotificationTabNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _currentIndex = widget.currentIndex;
    }
  }

  double measureTextWidth(String text) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 16.sp,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          height: 1.38,
          letterSpacing: -0.32,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return painter.size.width;
  }

  @override
  Widget build(BuildContext context) {
    final double widthAll = measureTextWidth('Tất cả');
    final double widthDisease = measureTextWidth('Các bệnh');
    final double widthHealth = measureTextWidth('Sống khỏe');

    // Tính toán vị trí các tab
    final List<double> tabLefts = [0, widthAll + 20.w, widthAll + widthDisease + 40.w];
    final List<double> tabWidths = [widthAll, widthDisease, widthHealth];

    return Container(
      width: double.infinity,
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Center(
        child: Container(
          width: widthAll + widthDisease + widthHealth + 40.w,
          height: 30.h,
          child: Stack(
            children: [
              // Moving underline for active tab
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                left: tabLefts[_currentIndex],
                top: 27.h,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: tabWidths[_currentIndex],
                  height: 4.h,
                  decoration: const BoxDecoration(color: Color(0xFF1877F2)),
                ),
              ),
              // Tab "Tất cả"
              Positioned(
                left: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _currentIndex = 0);
                    widget.onChanged?.call(0);
                  },
                  child: Text(
                    'Tất cả',
                    style: TextStyle(
                      color: _currentIndex == 0 ? Colors.black : const Color(0xFF4E4B66),
                      fontSize: 16.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.38,
                      letterSpacing: -0.32,
                    ),
                  ),
                ),
              ),
              // Tab "Các bệnh"
              Positioned(
                left: widthAll + 20.w,
                top: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _currentIndex = 1);
                    widget.onChanged?.call(1);
                  },
                  child: Text(
                    'Các bệnh',
                    style: TextStyle(
                      color: _currentIndex == 1 ? Colors.black : const Color(0xFF4E4B66),
                      fontSize: 16.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.38,
                      letterSpacing: -0.32,
                    ),
                  ),
                ),
              ),
              // Tab "Sống khỏe"
              Positioned(
                left: widthAll + widthDisease + 40.w,
                top: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _currentIndex = 2);
                    widget.onChanged?.call(2);
                  },
                  child: Text(
                    'Sống khỏe',
                    style: TextStyle(
                      color: _currentIndex == 2 ? Colors.black : const Color(0xFF4E4B66),
                      fontSize: 16.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.38,
                      letterSpacing: -0.32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

