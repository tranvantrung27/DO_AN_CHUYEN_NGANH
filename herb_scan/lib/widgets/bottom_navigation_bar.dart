import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 92.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                iconPath: 'assets/icons/icon_navigtion/home.png',
                label: 'Trang chủ',
              ),
              _buildNavItem(
                index: 1,
                iconPath: 'assets/icons/icon_navigtion/history.png',
                label: 'Lịch sử',
              ),
              _buildNavItem(
                index: 2,
                iconPath: 'assets/icons/icon_navigtion/scan.png',
                label: 'Quét',
              ),
              _buildNavItem(
                index: 3,
                iconPath: 'assets/icons/icon_navigtion/herballibrary.png',
                label: 'Kho thuốc',
              ),
              _buildNavItem(
                index: 4,
                iconPath: 'assets/icons/icon_navigtion/setting.png',
                label: 'Cài đặt',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String iconPath,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 70.w,
        height: 70.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 32.w,
              height: 32.h,
              color: isSelected ? AppColors.primaryGreen : Colors.grey[600],
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primaryGreen : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
