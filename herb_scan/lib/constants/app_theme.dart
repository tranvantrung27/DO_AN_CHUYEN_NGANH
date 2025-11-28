import 'package:flutter/material.dart';
import 'app_colors.dart';

/// File chứa cấu hình theme cho toàn bộ ứng dụng Herb Scan
/// Giúp quản lý theme tập trung và nhất quán
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ===== TEXT STYLES =====
  /// Text style cho heading lớn (splash screen)
  static const TextStyle headingLarge = TextStyle(
    fontSize: 63,
    fontFamily: 'Libre Franklin',
    fontWeight: FontWeight.w800,
    height: 1.25,
    letterSpacing: 1.26,
    color: AppColors.primaryGreen,
  );

  /// Text style cho heading vừa (intro titles)
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w700,
    height: 1.50,
    letterSpacing: 0.12,
    color: Colors.black,
  );

  /// Text style cho heading nhỏ (home screen)
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    height: 1.50,
    letterSpacing: 0.12,
    color: AppColors.primaryGreen,
  );

  /// Text style cho body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    height: 1.50,
    letterSpacing: 0.12,
    color: Color(0xFF4E4B66),
  );

  /// Text style cho body text nhỏ
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    height: 1.50,
    letterSpacing: 0.12,
    color: AppColors.textSecondary,
  );

  /// Text style cho button text
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    height: 1.50,
    letterSpacing: 0.12,
    color: Colors.white,
  );

  /// Text style cho caption/hint text
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    height: 1.50,
    letterSpacing: 0.12,
    color: AppColors.textLight,
  );

  // ===== BUTTON STYLES =====
  /// Style cho primary button
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryGreen,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
    textStyle: buttonText,
    elevation: 2,
    shadowColor: AppColors.shadowMedium,
  );

  /// Style cho secondary button
  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: AppColors.primaryGreen,
    side: const BorderSide(color: AppColors.primaryGreen, width: 1),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
    textStyle: buttonText.copyWith(color: AppColors.primaryGreen),
  );

  /// Style cho text button
  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
    foregroundColor: AppColors.primaryGreen,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    textStyle: buttonText.copyWith(color: AppColors.primaryGreen),
  );

  // ===== CONTAINER DECORATIONS =====
  /// Decoration cho card
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// Decoration cho bottom sheet
  static BoxDecoration get bottomSheetDecoration => const BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    ),
  );

  /// Decoration cho input field
  static InputDecoration inputDecoration({
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) => InputDecoration(
    hintText: hintText,
    labelText: labelText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    hintStyle: bodyMedium.copyWith(color: AppColors.textLight),
    labelStyle: bodyMedium.copyWith(color: AppColors.textSecondary),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.borderLight),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.borderLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    filled: true,
    fillColor: Colors.white,
  );

  // ===== THEME DATA =====
  /// Light theme cho ứng dụng
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.backgroundCream,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: secondaryButtonStyle,
    ),
    textButtonTheme: TextButtonThemeData(
      style: textButtonStyle,
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: bodyMedium.copyWith(color: AppColors.textLight),
      labelStyle: bodyMedium.copyWith(color: AppColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.white,
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      shadowColor: AppColors.shadowLight,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    ),
    fontFamily: 'Poppins',
  );

  /// Dark theme cho ứng dụng
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: buttonText,
        elevation: 2,
        shadowColor: AppColors.shadowMedium,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        side: const BorderSide(color: AppColors.primaryGreen, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: buttonText.copyWith(color: AppColors.primaryGreen),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: buttonText.copyWith(color: AppColors.primaryGreen),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: bodyMedium.copyWith(color: const Color(0xFF999999)),
      labelStyle: bodyMedium.copyWith(color: const Color(0xFFB0B0B0)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF424242)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF424242)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    ),
    dividerColor: const Color(0xFF424242),
    fontFamily: 'Poppins',
  );
}
