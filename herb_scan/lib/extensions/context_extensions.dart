import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/index.dart';

/// Extension methods cho BuildContext để dễ dàng truy cập theme, navigator, etc.
extension ContextExtensions on BuildContext {
  // ===== THEME ACCESS =====
  /// Truy cập theme data hiện tại
  ThemeData get theme => Theme.of(this);
  
  /// Truy cập color scheme hiện tại
  ColorScheme get colorScheme => theme.colorScheme;
  
  /// Truy cập text theme hiện tại
  TextTheme get textTheme => theme.textTheme;

  // ===== SCREEN DIMENSIONS =====
  /// Chiều rộng màn hình
  double get screenWidth => MediaQuery.of(this).size.width;
  
  /// Chiều cao màn hình
  double get screenHeight => MediaQuery.of(this).size.height;
  
  /// Safe area padding
  EdgeInsets get padding => MediaQuery.of(this).padding;
  
  /// View insets (keyboard height)
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  
  /// Kiểm tra có keyboard hiển thị không
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  // ===== RESPONSIVE HELPERS =====
  /// Responsive width (sử dụng ScreenUtil)
  double width(double size) => size.w;
  
  /// Responsive height (sử dụng ScreenUtil)
  double height(double size) => size.h;
  
  /// Responsive font size (sử dụng ScreenUtil)
  double fontSize(double size) => size.sp;
  
  /// Responsive radius (sử dụng ScreenUtil)
  double radius(double size) => size.r;

  // ===== NAVIGATION =====
  /// Navigator state
  NavigatorState get navigator => Navigator.of(this);
  
  /// Push route
  Future<T?> push<T>(Widget page) {
    return navigator.push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }
  
  /// Push replacement
  Future<T?> pushReplacement<T, TO>(Widget page) {
    return navigator.pushReplacement<T, TO>(
      MaterialPageRoute(builder: (_) => page),
    );
  }
  
  /// Push and remove until
  Future<T?> pushAndRemoveUntil<T>(Widget page, bool Function(Route) predicate) {
    return navigator.pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      predicate,
    );
  }
  
  /// Pop
  void pop<T>([T? result]) => navigator.pop(result);
  
  /// Can pop
  bool get canPop => navigator.canPop();

  // ===== SNACKBAR =====
  /// Hiển thị snackbar
  void showSnackBar(
    String message, {
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.bodyMedium.copyWith(
            color: textColor ?? Colors.white,
          ),
        ),
        backgroundColor: backgroundColor ?? AppColors.primaryGreen,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
  
  /// Hiển thị success snackbar
  void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: AppColors.success,
    );
  }
  
  /// Hiển thị error snackbar
  void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: AppColors.error,
    );
  }
  
  /// Hiển thị warning snackbar
  void showWarningSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: AppColors.warning,
    );
  }

  // ===== DIALOGS =====
  /// Hiển thị loading dialog
  void showLoadingDialog({String? message}) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            SizedBox(width: 16.w),
            Text(message ?? 'Đang tải...'),
          ],
        ),
      ),
    );
  }
  
  /// Ẩn loading dialog
  void hideLoadingDialog() {
    if (canPop) pop();
  }
  
  /// Hiển thị confirm dialog
  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Xác nhận',
    String cancelText = 'Hủy',
  }) {
    return showDialog<bool>(
      context: this,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // ===== FOCUS =====
  /// Unfocus keyboard
  void unfocus() => FocusScope.of(this).unfocus();
  
  /// Request focus
  void requestFocus(FocusNode focusNode) {
    FocusScope.of(this).requestFocus(focusNode);
  }

  // ===== DEVICE INFO =====
  /// Kiểm tra có phải tablet không
  bool get isTablet => screenWidth > 600;
  
  /// Kiểm tra có phải mobile không
  bool get isMobile => screenWidth <= 600;
  
  /// Kiểm tra orientation
  bool get isPortrait => screenHeight > screenWidth;
  bool get isLandscape => screenWidth > screenHeight;
}
