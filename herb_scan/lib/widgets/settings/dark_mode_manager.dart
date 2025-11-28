import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service quản lý dark mode preference và theme state
class DarkModeManager {
  static const String _darkModeKey = 'darkMode';
  
  // ValueNotifier để notify theme changes
  static final ValueNotifier<bool> _isDarkModeNotifier = ValueNotifier<bool>(false);
  
  /// Stream để listen theme changes
  static ValueNotifier<bool> get isDarkModeNotifier => _isDarkModeNotifier;

  /// Load dark mode preference từ SharedPreferences
  static Future<bool> loadDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    _isDarkModeNotifier.value = isDarkMode;
    return isDarkMode;
  }

  /// Lưu dark mode preference vào SharedPreferences và notify listeners
  static Future<void> saveDarkModePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDarkMode);
    _isDarkModeNotifier.value = isDarkMode;
  }

  /// Get current dark mode state
  static bool get isDarkMode => _isDarkModeNotifier.value;

  /// Initialize dark mode from SharedPreferences
  static Future<void> initialize() async {
    await loadDarkModePreference();
  }
}

