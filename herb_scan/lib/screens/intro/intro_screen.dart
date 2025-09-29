import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'intro_main_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    // Chuyển sang màn hình chính sau 3 giây
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const IntroMainScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: Container(
        width: 430,
        height: 932,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: AppColors.backgroundCream),
        child: Stack(
          children: [
            // Logo với khung scan ở vị trí cụ thể
            Positioned(
              left: 60,
              top: 208,
              child: Container(
                width: 310,
                height: 310,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/IconApp/app_icon.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Text "Herb Scan" ở vị trí cụ thể
            Positioned(
              left: 52,
              top: 595,
              child: Text(
                'Herb Scan',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 63,
                  fontFamily: 'Libre Franklin',
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  letterSpacing: 1.26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
