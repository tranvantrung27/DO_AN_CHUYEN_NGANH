import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_animations.dart';

/// Widget hiển thị các chấm indicator với animation
/// Được tái sử dụng cho các màn hình có pagination
class AnimatedDotIndicator extends StatefulWidget {
  /// Số lượng chấm
  final int itemCount;
  
  /// Index hiện tại
  final int currentIndex;
  
  /// Màu của chấm active
  final Color activeColor;
  
  /// Màu của chấm inactive
  final Color inactiveColor;
  
  /// Kích thước chấm active
  final double activeSize;
  
  /// Kích thước chấm inactive
  final double inactiveSize;
  
  /// Khoảng cách giữa các chấm
  final double spacing;
  
  /// Duration của animation
  final Duration animationDuration;
  
  /// Curve của animation
  final Curve animationCurve;
  
  /// Có hiển thị shadow không
  final bool showShadow;
  
  /// Có hiển thị bounce effect không
  final bool showBounceEffect;

  const AnimatedDotIndicator({
    super.key,
    required this.itemCount,
    required this.currentIndex,
    this.activeColor = AppColors.primaryGreen,
    this.inactiveColor = const Color(0xFFA0A3BD),
    this.activeSize = AppAnimations.dotActiveSize,
    this.inactiveSize = AppAnimations.dotInactiveSize,
    this.spacing = AppAnimations.dotSpacing,
    this.animationDuration = AppAnimations.normal,
    this.animationCurve = AppAnimations.easeInOut,
    this.showShadow = true,
    this.showBounceEffect = true,
  }) : assert(itemCount > 0, 'Item count must be greater than 0'),
       assert(currentIndex >= 0 && currentIndex < itemCount, 
              'Current index must be within item count range');

  @override
  State<AnimatedDotIndicator> createState() => _AnimatedDotIndicatorState();
}

class _AnimatedDotIndicatorState extends State<AnimatedDotIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _bounceAnimations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationControllers = List.generate(widget.itemCount, (index) {
      return AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      );
    });

    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(
        begin: AppAnimations.dotInactiveScale,
        end: AppAnimations.dotActiveScale,
      ).animate(
        CurvedAnimation(parent: controller, curve: widget.animationCurve),
      );
    }).toList();

    if (widget.showBounceEffect) {
      _bounceAnimations = _animationControllers.map((controller) {
        return Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: controller, curve: AppAnimations.bounce),
        );
      }).toList();
    } else {
      _bounceAnimations = _animationControllers.map((controller) {
        return Tween<double>(begin: 1.0, end: 1.0).animate(controller);
      }).toList();
    }

    // Animate current dot
    _animationControllers[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(AnimatedDotIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Reset old animation
      if (oldWidget.currentIndex < _animationControllers.length) {
        _animationControllers[oldWidget.currentIndex].reverse();
      }
      // Start new animation
      if (widget.currentIndex < _animationControllers.length) {
        _animationControllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.itemCount, (index) {
        return AnimatedBuilder(
          animation: _animationControllers[index],
          builder: (context, child) {
            final isActive = index == widget.currentIndex;
            
            return Container(
              margin: EdgeInsets.only(
                right: index < widget.itemCount - 1 ? widget.spacing : 0,
              ),
              child: Transform.scale(
                scale: isActive 
                    ? _scaleAnimations[index].value 
                    : AppAnimations.dotInactiveScale,
                child: AnimatedContainer(
                  duration: widget.animationDuration,
                  curve: widget.animationCurve,
                  width: isActive ? widget.activeSize : widget.inactiveSize,
                  height: isActive ? widget.activeSize : widget.inactiveSize,
                  decoration: BoxDecoration(
                    color: isActive ? widget.activeColor : widget.inactiveColor,
                    shape: BoxShape.circle,
                    boxShadow: isActive && widget.showShadow ? [
                      BoxShadow(
                        color: widget.activeColor.withValues(alpha: AppAnimations.shadowOpacity),
                        blurRadius: AppAnimations.shadowMediumBlur,
                        offset: AppAnimations.shadowOffset,
                      ),
                    ] : null,
                  ),
                  child: isActive && widget.showBounceEffect
                      ? Transform.scale(
                          scale: _bounceAnimations[index].value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: AppAnimations.overlayOpacity),
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
