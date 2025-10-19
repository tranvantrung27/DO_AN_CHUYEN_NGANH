import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../extensions/string_extensions.dart';

/// Utility class chứa các helper methods tổng quát
class AppUtils {
  AppUtils._(); // Private constructor

  // ===== DATE & TIME UTILITIES =====
  
  /// Format DateTime thành string
  static String formatDate(DateTime date, {String pattern = 'dd/MM/yyyy'}) {
    return DateFormat(pattern, 'vi_VN').format(date);
  }

  /// Format DateTime thành string với time
  static String formatDateTime(DateTime date, {String pattern = 'dd/MM/yyyy HH:mm'}) {
    return DateFormat(pattern, 'vi_VN').format(date);
  }

  /// Format thành relative time (vd: "2 giờ trước")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years năm trước';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  /// Parse string thành DateTime
  static DateTime? parseDate(String dateString, {String pattern = 'dd/MM/yyyy'}) {
    try {
      return DateFormat(pattern, 'vi_VN').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Kiểm tra có phải hôm nay không
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Kiểm tra có phải hôm qua không
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }

  // ===== NUMBER & CURRENCY UTILITIES =====
  
  /// Format số thành currency VND
  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(amount);
  }

  /// Format số với thousands separator
  static String formatNumber(num number, {int decimalDigits = 0}) {
    return NumberFormat('#,##0', 'vi_VN').format(number);
  }

  /// Parse currency string thành double
  static double? parseCurrency(String currencyString) {
    try {
      final cleanString = currencyString
          .replaceAll('₫', '')
          .replaceAll(',', '')
          .replaceAll('.', '')
          .trim();
      return double.parse(cleanString);
    } catch (e) {
      return null;
    }
  }

  /// Generate random number trong khoảng
  static int randomInt(int min, int max) {
    return min + Random().nextInt(max - min + 1);
  }

  /// Generate random double trong khoảng
  static double randomDouble(double min, double max) {
    return min + Random().nextDouble() * (max - min);
  }

  // ===== STRING UTILITIES =====
  
  /// Generate random string
  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  /// Generate UUID-like string
  static String generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${generateRandomString(6)}';
  }

  /// Truncate string với ellipsis
  static String truncateString(String text, int maxLength, {String ellipsis = '...'}) {
    return text.truncate(maxLength, ellipsis: ellipsis);
  }

  /// Highlight search keyword trong text
  static List<TextSpan> highlightText(
    String text,
    String keyword, {
    TextStyle? normalStyle,
    TextStyle? highlightStyle,
  }) {
    return text.highlightKeyword(
      keyword,
      normalStyle: normalStyle,
      highlightStyle: highlightStyle,
    );
  }

  // ===== FILE & STORAGE UTILITIES =====
  
  /// Lấy file size dạng human readable
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Lấy file extension
  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  /// Kiểm tra file có phải là image không
  static bool isImageFile(String filePath) {
    return filePath.isImageFile;
  }

  /// Generate file name unique
  static String generateFileName(String originalName) {
    final extension = getFileExtension(originalName);
    final nameWithoutExt = originalName.replaceAll('.$extension', '');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${nameWithoutExt}_$timestamp.$extension';
  }

  // ===== DEVICE & PLATFORM UTILITIES =====
  
  /// Kiểm tra có phải Android không
  static bool get isAndroid => Platform.isAndroid;
  
  /// Kiểm tra có phải iOS không
  static bool get isIOS => Platform.isIOS;
  
  /// Kiểm tra có phải mobile platform không
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  /// Copy text vào clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Paste text từ clipboard
  static Future<String?> pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    return clipboardData?.text;
  }

  /// Vibrate device
  static Future<void> vibrate({int duration = 100}) async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Ignore errors on unsupported devices
    }
  }

  // ===== UI UTILITIES =====
  
  /// Lấy screen size
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Kiểm tra có phải tablet không
  static bool isTablet(BuildContext context) {
    return getScreenSize(context).shortestSide >= 600;
  }

  /// Kiểm tra orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Lấy status bar height
  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// Lấy bottom safe area height
  static double getBottomSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  /// Hide keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Show keyboard
  static void showKeyboard(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  // ===== VALIDATION UTILITIES =====
  
  /// Validate email
  static bool isValidEmail(String email) {
    return email.isValidEmail;
  }

  /// Validate Vietnamese phone number
  static bool isValidVietnamesePhone(String phone) {
    return phone.isValidVietnamesePhone;
  }

  /// Validate URL
  static bool isValidUrl(String url) {
    return url.isValidUrl;
  }

  /// Validate strong password
  static bool isStrongPassword(String password) {
    return password.isStrongPassword;
  }

  // ===== COLOR UTILITIES =====
  
  /// Convert hex string to Color
  static Color hexToColor(String hex) {
    return hex.toColor;
  }

  /// Convert Color to hex string
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Generate random color
  static Color randomColor() {
    return Color.fromRGBO(
      Random().nextInt(256),
      Random().nextInt(256),
      Random().nextInt(256),
      1,
    );
  }

  /// Get contrasting text color (black or white) cho background color
  static Color getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // ===== NETWORK UTILITIES =====
  
  /// Kiểm tra có internet connection không (cần implement với connectivity_plus)
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // ===== PERFORMANCE UTILITIES =====
  
  /// Debounce function calls
  static void debounce(
    String key,
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    _DebounceHelper.debounce(key, callback, delay: delay);
  }

  /// Throttle function calls
  static void throttle(
    String key,
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    _ThrottleHelper.throttle(key, callback, duration: duration);
  }
}

/// Helper class cho debounce
class _DebounceHelper {
  static final Map<String, Timer?> _timers = {};

  static void debounce(String key, VoidCallback callback, {required Duration delay}) {
    _timers[key]?.cancel();
    _timers[key] = Timer(delay, callback);
  }
}

/// Helper class cho throttle
class _ThrottleHelper {
  static final Map<String, DateTime> _lastCalls = {};

  static void throttle(String key, VoidCallback callback, {required Duration duration}) {
    final now = DateTime.now();
    final lastCall = _lastCalls[key];
    
    if (lastCall == null || now.difference(lastCall) >= duration) {
      _lastCalls[key] = now;
      callback();
    }
  }
}

