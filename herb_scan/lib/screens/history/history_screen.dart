import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../../widgets/history_tab_navigation.dart';
import 'collection_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedTab = 0; // 0: Lịch sử (trang chính), 1: Bộ sưu tầm

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: Stack(
          children: [
            // Tab Navigation
            Positioned(
              left: 75.w,
              top: 80.h,
              child: HistoryTabNavigation(
                selectedTab: _selectedTab,
                onTabChanged: (index) {
                  setState(() {
                    _selectedTab = index;
                  });
                },
              ),
            ),
            
            // Content based on selected tab
            // Tab 0: Lịch sử (trang chính) - hiển thị khi mở màn hình
            // Tab 1: Bộ sưu tầm - chuyển qua khi tap tab
            Positioned(
              left: 0,
              top: 150.h,
              child: _selectedTab == 0 ? _buildHistoryContent() : const CollectionScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryContent() {
    return Container(
      width: 430.w,
      height: 782.h,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Color(0xFFF5EEE0)),
      child: Stack(
        children: [
          // Main content - Empty state
          Positioned(
            left: 50.w,
            top: 70.h,
            child: SizedBox(
              width: 330.w,
              height: 330.h,
              child: Image.asset(
                "assets/icons/history.png",
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading history image: $error');
                  return Container(
                    width: 330.w,
                    height: 330.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.history,
                      size: 100,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Empty state text
          Positioned(
            left: 52.w,
            top: 460.h,
            child: Text(
              'Lịch sử chưa được ghi nhận',
              style: TextStyle(
                color: const Color(0xFF3B7254),
                fontSize: 24.sp,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w900,
                height: 1.25,
                letterSpacing: 0.48,
              ),
            ),
          ),
          
          Positioned(
            left: 51.w,
            top: 500.h,
            child: Text(
              'Hãy bắt đầu khám phá \nđể theo dõi các hoạt động của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF3B7254),
                fontSize: 20.sp,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w500,
                height: 1.25,
                letterSpacing: 0.40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
