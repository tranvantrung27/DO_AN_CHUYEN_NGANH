import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/login/login_screen.dart';
import '../screens/main_navigation_screen.dart';

/// Widget wrapper để kiểm tra auth state và điều hướng đến đúng màn hình
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder để listen vào auth state changes
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Đang loading, hiển thị loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Nếu có user (đã đăng nhập), điều hướng đến MainNavigationScreen
        if (snapshot.hasData && snapshot.data != null) {
          return const MainNavigationScreen();
        }

        // Nếu không có user (chưa đăng nhập hoặc đã đăng xuất), điều hướng đến LoginScreen
        return const LoginScreen();
      },
    );
  }
}

