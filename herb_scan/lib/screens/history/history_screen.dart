import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: Center(
          child: Text(
            'Đây là trang Lịch sử',
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
