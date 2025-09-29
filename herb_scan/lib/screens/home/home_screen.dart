import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Herb Scan'),
        backgroundColor: AppColors.secondaryGreen,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 100,
              color: AppColors.primaryGreen,
            ),
            SizedBox(height: 20),
            Text(
              'Chào mừng đến với Herb Scan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Ứng dụng nhận diện lá cây thuốc Việt Nam',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
