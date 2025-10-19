import 'package:flutter/material.dart';

/// File chứa tất cả animation constants của ứng dụng Herb Scan
/// Giúp quản lý animation tập trung và dễ thay đổi
class AppAnimations {
  // Private constructor to prevent instantiation
  AppAnimations._();

  // ===== DURATIONS =====
  /// Animation duration cho các hiệu ứng nhanh (button press, hover)
  static const Duration fast = Duration(milliseconds: 150);
  
  /// Animation duration cho các hiệu ứng bình thường (transition, fade)
  static const Duration normal = Duration(milliseconds: 300);
  
  /// Animation duration cho các hiệu ứng chậm (page transition)
  static const Duration slow = Duration(milliseconds: 500);
  
  /// Animation duration cho splash screen
  static const Duration splash = Duration(seconds: 3);

  // ===== CURVES =====
  /// Curve cho hiệu ứng mượt mà cơ bản
  static const Curve easeInOut = Curves.easeInOut;
  
  /// Curve cho hiệu ứng bounce
  static const Curve bounce = Curves.elasticOut;
  
  /// Curve cho hiệu ứng xuất hiện
  static const Curve fadeIn = Curves.easeIn;
  
  /// Curve cho hiệu ứng biến mất
  static const Curve fadeOut = Curves.easeOut;

  // ===== DOT INDICATOR ANIMATIONS =====
  /// Kích thước chấm khi active
  static const double dotActiveSize = 16.0;
  
  /// Kích thước chấm khi inactive
  static const double dotInactiveSize = 12.0;
  
  /// Scale factor cho chấm active
  static const double dotActiveScale = 1.0;
  
  /// Scale factor cho chấm inactive
  static const double dotInactiveScale = 0.8;
  
  /// Khoảng cách giữa các chấm
  static const double dotSpacing = 8.0;

  // ===== PAGE TRANSITION ANIMATIONS =====
  /// Duration cho page transition
  static const Duration pageTransition = Duration(milliseconds: 300);
  
  /// Curve cho page transition
  static const Curve pageTransitionCurve = Curves.easeInOut;

  // ===== SHADOW ANIMATIONS =====
  /// Blur radius cho shadow nhẹ
  static const double shadowLightBlur = 4.0;
  
  /// Blur radius cho shadow vừa
  static const double shadowMediumBlur = 8.0;
  
  /// Blur radius cho shadow nặng
  static const double shadowHeavyBlur = 16.0;
  
  /// Offset cho shadow
  static const Offset shadowOffset = Offset(0, 2);

  // ===== SCALE ANIMATIONS =====
  /// Scale khi button được nhấn
  static const double buttonPressedScale = 0.95;
  
  /// Scale khi widget được hover
  static const double hoverScale = 1.05;

  // ===== OPACITY ANIMATIONS =====
  /// Opacity cho trạng thái disabled
  static const double disabledOpacity = 0.5;
  
  /// Opacity cho overlay
  static const double overlayOpacity = 0.3;
  
  /// Opacity cho shadow
  static const double shadowOpacity = 0.3;

  // ===== ANIMATION HELPER METHODS =====
  /// Tạo animation controller với duration mặc định
  static AnimationController createController({
    required TickerProvider vsync,
    Duration? duration,
  }) {
    return AnimationController(
      duration: duration ?? normal,
      vsync: vsync,
    );
  }

  /// Tạo scale animation
  static Animation<double> createScaleAnimation({
    required AnimationController controller,
    double begin = 0.0,
    double end = 1.0,
    Curve curve = easeInOut,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  /// Tạo fade animation
  static Animation<double> createFadeAnimation({
    required AnimationController controller,
    double begin = 0.0,
    double end = 1.0,
    Curve curve = easeInOut,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  /// Tạo slide animation
  static Animation<Offset> createSlideAnimation({
    required AnimationController controller,
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
    Curve curve = easeInOut,
  }) {
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }
}
