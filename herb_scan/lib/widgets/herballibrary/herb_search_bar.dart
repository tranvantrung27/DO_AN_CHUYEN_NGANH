import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

/// Widget search bar với typing animation
/// Hiển thị text với hiệu ứng gõ từ trái sang phải và tự động lặp lại
class HerbSearchBar extends StatefulWidget {
  final VoidCallback? onTap;
  final String placeholder;
  
  const HerbSearchBar({
    super.key,
    this.onTap,
    this.placeholder = 'Tìm bài thuốc theo triệu chứng (ho,mất ngủ…)',
  });

  @override
  State<HerbSearchBar> createState() => _HerbSearchBarState();
}

class _HerbSearchBarState extends State<HerbSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _typingController;
  late Animation<int> _typingAnimation;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      duration: Duration(milliseconds: widget.placeholder.length * 50), // 50ms per character
      vsync: this,
    );

    _typingAnimation = IntTween(
      begin: 0,
      end: widget.placeholder.length,
    ).animate(CurvedAnimation(
      parent: _typingController,
      curve: Curves.linear,
    ));

    // Add listener to repeat animation
    _typingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Wait a bit before repeating
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _typingController.reset();
            _typingController.forward();
          }
        });
      }
    });

    // Start animation
    _typingController.forward();
  }

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        height: 50.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(56.r),
          ),
          shadows: [
            BoxShadow(
              color: const Color(0x11000000),
              blurRadius: 14,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Search icon
            Image.asset(
              'assets/icons/sreach.png',
              width: 20.w,
              height: 20.w,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 12.w),
            // Search text with typing animation
            Expanded(
              child: AnimatedBuilder(
                animation: _typingAnimation,
                builder: (context, child) {
                  final displayedText = widget.placeholder.substring(
                    0,
                    _typingAnimation.value,
                  );
                  return Text(
                    displayedText,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

