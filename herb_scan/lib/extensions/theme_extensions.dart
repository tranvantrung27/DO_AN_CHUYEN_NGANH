import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Extension để dễ dàng truy cập theme colors
extension ThemeExtensions on BuildContext {
  /// Get scaffold background color (adapts to dark/light mode)
  Color get scaffoldBgColor => Theme.of(this).scaffoldBackgroundColor;
  
  /// Get card color (adapts to dark/light mode)
  Color get cardColor => Theme.of(this).cardColor;
  
  /// Get primary text color (adapts to dark/light mode)
  Color get primaryTextColor => Theme.of(this).textTheme.bodyLarge?.color ?? 
                               (Theme.of(this).brightness == Brightness.dark 
                                   ? Colors.white 
                                   : AppColors.textPrimary);
  
  /// Get secondary text color (adapts to dark/light mode)
  Color get secondaryTextColor => Theme.of(this).textTheme.bodyMedium?.color ?? 
                                  (Theme.of(this).brightness == Brightness.dark 
                                      ? Colors.grey[300]! 
                                      : AppColors.textSecondary);
  
  /// Check if dark mode is active
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

