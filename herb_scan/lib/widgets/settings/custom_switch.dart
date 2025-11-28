import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget switch tùy chỉnh với animation
class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged; // Nullable để có thể disable

  const CustomSwitch({
    super.key,
    required this.value,
    this.onChanged, // Optional - nếu null thì switch bị disable
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onChanged != null;
    return GestureDetector(
      onTap: isEnabled ? () => onChanged!(!value) : null,
      child: Container(
        width: 52.w,
        height: 28.h,
        decoration: ShapeDecoration(
          color: isEnabled 
              ? (value ? const Color(0xFF3AAF3D) : const Color(0xFFE0E0E0))
              : const Color(0xFFE0E0E0), // Luôn màu xám khi disabled
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 26.w : 2.w,
              top: 2.h,
              child: Container(
                width: 24.w,
                height: 24.w,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: const OvalBorder(),
                  shadows: [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 1,
                      offset: Offset(0, 1),
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

