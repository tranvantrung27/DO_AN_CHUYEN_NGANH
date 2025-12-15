import 'package:flutter/material.dart';

/// File chứa tất cả màu sắc của ứng dụng Herb Scan
/// Giúp quản lý màu sắc tập trung và dễ thay đổi
class AppColors {
  // Màu chính của app
  static const Color primaryGreen = Color(0xFF3AAF3D);
  static const Color secondaryGreen = Color(0xFF2E7D32);
  
  // Màu nền
  static const Color backgroundCream = Color(0xFFF5EEE0);
  static const Color backgroundGrey = Color(0xFFF8F7F6); // Màu nền xám nhạt cho feedback
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  
  // Màu chữ
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textPrimaryDark = Color(0xFF111827); // Màu chữ đen đậm
  static const Color textPrimaryMedium = Color(0xFF1F2937); // Màu chữ đen trung bình
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);
  static const Color textPlaceholder = Color(0xFF9CA3AF); // Màu placeholder
  static const Color textBrown = Color(0xFF887B63); // Màu nâu cho text date
  
  // Màu trạng thái
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFD0BB95); // Màu warning nhạt cho feedback
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  static const Color orange = Color(0xFFE69E19); // Màu cam cho email và button
  
  // Màu border và divider
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderMedium = Color(0xFFBDBDBD);
  static const Color borderGrey = Color(0xFFD1D5DB); // Màu border xám
  
  // Màu nền phụ
  static const Color backgroundGreyLight = Color(0xFFE5E7EB); // Màu nền xám nhạt cho button
  static const Color overlayDark = Color(0xCC4B5563); // Màu overlay tối cho nút xóa
  
  // Màu shadow
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  
  // Màu gradient (nếu cần)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, secondaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Màu cho các tab/chức năng chính
  static const Color tabHome = Color(0xFF3AAF3D);
  static const Color tabScan = Color(0xFF2196F3);
  static const Color tabHistory = Color(0xFF9C27B0);
  static const Color tabCollection = Color(0xFFFF9800);
  static const Color tabSettings = Color(0xFF607D8B);
}
