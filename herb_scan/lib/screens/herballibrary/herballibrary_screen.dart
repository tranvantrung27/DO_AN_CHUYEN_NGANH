import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

class HerbLibraryScreen extends StatefulWidget {
  const HerbLibraryScreen({super.key});

  @override
  State<HerbLibraryScreen> createState() => _HerbLibraryScreenState();
}

class _HerbLibraryScreenState extends State<HerbLibraryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: Center(
          child: Text(
            'Đây là trang Kho thuốc',
            style: TextStyle(
              fontSize: 18.sp,
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
