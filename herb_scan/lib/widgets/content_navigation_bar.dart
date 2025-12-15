import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContentNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int>? onChanged;
  const ContentNavigationBar({super.key, this.currentIndex = 0, this.onChanged});

  @override
  State<ContentNavigationBar> createState() => _ContentNavigationBarState();
}

class _ContentNavigationBarState extends State<ContentNavigationBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant ContentNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _currentIndex = widget.currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Base text style used to measure label widths
    final TextStyle baseLabelStyle = TextStyle(
      fontSize: 16.sp,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
      height: 1.38,
      letterSpacing: -0.32,
    );

    double measureTextWidth(String text) {
      final TextPainter painter = TextPainter(
        text: TextSpan(text: text, style: baseLabelStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(minWidth: 0, maxWidth: double.infinity);
      return painter.size.width;
    }

    final double widthNews = measureTextWidth('Tin tức');
    final double widthDisease = measureTextWidth('Các bệnh');
    final double widthHealth = measureTextWidth('Sống khỏe');

    final List<double> tabLefts = [0, 66.w, 151.w];
    final List<double> tabWidths = [widthNews, widthDisease, widthHealth];

    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: Center(
        child: SizedBox(
          width: 229.w,
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
              // Tab "Tin tức"
              Positioned(
                left: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _currentIndex = 0);
                    widget.onChanged?.call(0);
                  },
                  child: Container(
                    width: 51.w,
                    height: 30.h,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: Stack(
                      children: [
                        // Text
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Text(
                            'Tin tức',
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
                      ],
                    ),
                  ),
                ),
              ),
              
              // Tab "Các bệnh"
              Positioned(
                left: 66.w,
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
                left: 151.w,
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
