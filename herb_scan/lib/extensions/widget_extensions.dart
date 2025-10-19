import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/index.dart';

/// Extension methods cho Widget để tạo animations và styling dễ dàng hơn
extension WidgetExtensions on Widget {
  // ===== PADDING & MARGIN =====
  /// Thêm padding cho widget
  Widget paddingAll(double value) => Padding(
    padding: EdgeInsets.all(value.r),
    child: this,
  );
  
  /// Thêm symmetric padding
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) => Padding(
    padding: EdgeInsets.symmetric(
      horizontal: horizontal.w,
      vertical: vertical.h,
    ),
    child: this,
  );
  
  /// Thêm padding từng phía
  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => Padding(
    padding: EdgeInsets.only(
      left: left.w,
      top: top.h,
      right: right.w,
      bottom: bottom.h,
    ),
    child: this,
  );
  
  /// Thêm margin (sử dụng Container)
  Widget marginAll(double value) => Container(
    margin: EdgeInsets.all(value.r),
    child: this,
  );
  
  /// Thêm symmetric margin
  Widget marginSymmetric({double horizontal = 0, double vertical = 0}) => Container(
    margin: EdgeInsets.symmetric(
      horizontal: horizontal.w,
      vertical: vertical.h,
    ),
    child: this,
  );
  
  /// Thêm margin từng phía
  Widget marginOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => Container(
    margin: EdgeInsets.only(
      left: left.w,
      top: top.h,
      right: right.w,
      bottom: bottom.h,
    ),
    child: this,
  );

  // ===== SIZING =====
  /// Set kích thước cố định
  Widget size({double? width, double? height}) => SizedBox(
    width: width?.w,
    height: height?.h,
    child: this,
  );
  
  /// Set chiều rộng
  Widget width(double width) => SizedBox(
    width: width.w,
    child: this,
  );
  
  /// Set chiều cao
  Widget height(double height) => SizedBox(
    height: height.h,
    child: this,
  );
  
  /// Expand widget
  Widget get expanded => Expanded(child: this);
  
  /// Flexible widget
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) => Flexible(
    flex: flex,
    fit: fit,
    child: this,
  );

  // ===== ALIGNMENT & POSITIONING =====
  /// Center widget
  Widget get centered => Center(child: this);
  
  /// Align widget
  Widget align(Alignment alignment) => Align(
    alignment: alignment,
    child: this,
  );
  
  /// Positioned widget (chỉ dùng trong Stack)
  Widget positioned({
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? width,
    double? height,
  }) => Positioned(
    left: left?.w,
    top: top?.h,
    right: right?.w,
    bottom: bottom?.h,
    width: width?.w,
    height: height?.h,
    child: this,
  );

  // ===== DECORATION & STYLING =====
  /// Thêm background color
  Widget backgroundColor(Color color) => Container(
    color: color,
    child: this,
  );
  
  /// Thêm border radius
  Widget borderRadius(double radius) => ClipRRect(
    borderRadius: BorderRadius.circular(radius.r),
    child: this,
  );
  
  /// Thêm border
  Widget border({
    Color color = Colors.grey,
    double width = 1,
    double radius = 0,
  }) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: color, width: width),
      borderRadius: BorderRadius.circular(radius.r),
    ),
    child: this,
  );
  
  /// Thêm shadow
  Widget shadow({
    Color color = Colors.black26,
    double blurRadius = 4,
    Offset offset = const Offset(0, 2),
  }) => Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: color,
          blurRadius: blurRadius,
          offset: offset,
        ),
      ],
    ),
    child: this,
  );
  
  /// Thêm card decoration
  Widget card({
    Color? color,
    double elevation = 2,
    double radius = 8,
  }) => Card(
    color: color,
    elevation: elevation,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius.r),
    ),
    child: this,
  );

  // ===== GESTURES =====
  /// Thêm tap gesture
  Widget onTap(VoidCallback? onTap, {bool opaque = true}) => GestureDetector(
    onTap: onTap,
    behavior: opaque ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
    child: this,
  );
  
  /// Thêm long press gesture
  Widget onLongPress(VoidCallback? onLongPress) => GestureDetector(
    onLongPress: onLongPress,
    child: this,
  );
  
  /// Thêm double tap gesture
  Widget onDoubleTap(VoidCallback? onDoubleTap) => GestureDetector(
    onDoubleTap: onDoubleTap,
    child: this,
  );

  // ===== ANIMATIONS (sử dụng flutter_animate) =====
  /// Fade in animation
  Widget fadeIn({
    Duration duration = AppAnimations.normal,
    Duration delay = Duration.zero,
    Curve curve = AppAnimations.fadeIn,
  }) => animate(delay: delay)
      .fadeIn(duration: duration, curve: curve);
  
  /// Slide in from left
  Widget slideInLeft({
    Duration duration = AppAnimations.normal,
    Duration delay = Duration.zero,
    Curve curve = AppAnimations.easeInOut,
  }) => animate(delay: delay)
      .slideX(
        begin: -1,
        end: 0,
        duration: duration,
        curve: curve,
      );
  
  /// Slide in from right
  Widget slideInRight({
    Duration duration = AppAnimations.normal,
    Duration delay = Duration.zero,
    Curve curve = AppAnimations.easeInOut,
  }) => animate(delay: delay)
      .slideX(
        begin: 1,
        end: 0,
        duration: duration,
        curve: curve,
      );
  
  /// Slide in from top
  Widget slideInTop({
    Duration duration = AppAnimations.normal,
    Duration delay = Duration.zero,
    Curve curve = AppAnimations.easeInOut,
  }) => animate(delay: delay)
      .slideY(
        begin: -1,
        end: 0,
        duration: duration,
        curve: curve,
      );
  
  /// Slide in from bottom
  Widget slideInBottom({
    Duration duration = AppAnimations.normal,
    Duration delay = Duration.zero,
    Curve curve = AppAnimations.easeInOut,
  }) => animate(delay: delay)
      .slideY(
        begin: 1,
        end: 0,
        duration: duration,
        curve: curve,
      );
  
  /// Scale animation
  Widget scaleIn({
    Duration duration = AppAnimations.normal,
    Duration delay = Duration.zero,
    Curve curve = AppAnimations.bounce,
    double begin = 0.0,
    double end = 1.0,
  }) => animate(delay: delay)
      .scale(
        begin: Offset(begin, begin),
        end: Offset(end, end),
        duration: duration,
        curve: curve,
      );
  
  /// Bounce animation
  Widget bounceIn({
    Duration duration = AppAnimations.slow,
    Duration delay = Duration.zero,
  }) => animate(delay: delay)
      .scale(
        begin: const Offset(0.3, 0.3),
        end: const Offset(1.0, 1.0),
        duration: duration,
        curve: AppAnimations.bounce,
      );
  
  /// Shimmer loading effect
  Widget shimmer({
    Color baseColor = const Color(0xFFE0E0E0),
    Color highlightColor = const Color(0xFFF5F5F5),
    Duration duration = const Duration(milliseconds: 1500),
  }) => animate(onPlay: (controller) => controller.repeat())
      .shimmer(
        duration: duration,
        color: highlightColor,
      );

  // ===== CONDITIONAL RENDERING =====
  /// Hiển thị widget nếu condition = true
  Widget showIf(bool condition) => condition ? this : const SizedBox.shrink();
  
  /// Hiển thị widget khác nếu condition = false
  Widget showIfElse(bool condition, Widget elseWidget) => condition ? this : elseWidget;

  // ===== SAFE AREA =====
  /// Wrap với SafeArea
  Widget get safeArea => SafeArea(child: this);
  
  /// Safe area chỉ top
  Widget get safeAreaTop => SafeArea(
    bottom: false,
    child: this,
  );
  
  /// Safe area chỉ bottom
  Widget get safeAreaBottom => SafeArea(
    top: false,
    child: this,
  );

  // ===== SCROLLING =====
  /// Wrap với SingleChildScrollView
  Widget get scrollable => SingleChildScrollView(child: this);
  
  /// Scrollable với axis
  Widget scrollableX() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: this,
  );

  // ===== HERO ANIMATION =====
  /// Wrap với Hero widget
  Widget hero(String tag) => Hero(
    tag: tag,
    child: this,
  );
}
