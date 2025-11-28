import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/index.dart';
import '../../../screens/login/login_screen.dart';

/// Service xử lý logic đăng xuất cho settings screen
class SettingsLogoutHandler {
  final AuthService _authService = AuthService();

  /// Hiển thị dialog xác nhận và xử lý đăng xuất
  Future<void> handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        // Clear SharedPreferences để xóa toàn bộ dữ liệu local
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          print('✅ Cleared SharedPreferences');
        } catch (e) {
          print('⚠️ Error clearing SharedPreferences: $e');
        }
        
        // Đăng xuất khỏi Firebase
        await _authService.signOut();
        print('✅ Signed out from Firebase');
        
        // Navigate về màn hình đăng nhập và clear toàn bộ navigation stack
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false, // Xóa tất cả routes trước đó
          );
        }
      } catch (e) {
        print('❌ Error during logout: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi đăng xuất: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

