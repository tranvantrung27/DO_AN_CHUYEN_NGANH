import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../constants/app_colors.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Thông tin giới thiệu',
          style: TextStyle(
            color: const Color(0xFF181511),
            fontSize: 18.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.25,
            letterSpacing: -0.27,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 24.h),
              // App Icon
              Container(
                width: 96.w,
                height: 96.h,
                decoration: BoxDecoration(
                  color: const Color(0x33E69E19), // Orange with 20% opacity
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.asset(
                    'assets/IconApp/app_icon.png',
                    width: 96.w,
                    height: 96.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              // App Name
              Text(
                'Herb Scan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF181511),
                  fontSize: 32.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 8.h),
              // Version
              Text(
                'Phiên bản 1.0.0',
                style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: 16.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
              SizedBox(height: 24.h),
              // Description
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'HerbScan là ứng dụng di động thông minh sử dụng công nghệ AI để nhận diện và cung cấp thông tin chi tiết về các loại thảo dược Việt Nam. Với cơ sở dữ liệu phong phú và độ chính xác cao, ứng dụng giúp bạn dễ dàng tìm hiểu về công dụng, cách sử dụng và lưu trữ lịch sử nhận diện, mang đến trải nghiệm khám phá thảo dược truyền thống một cách hiện đại và tiện lợi.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    color: const Color(0xFF181511),
                    fontSize: 16.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.63,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              // Info Cards
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWhite,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x0C000000),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMenuItem(
                        icon: Icons.description_outlined,
                        title: 'Điều khoản dịch vụ',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TermsConditionsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.shield_outlined,
                        title: 'Chính sách bảo mật',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.language_outlined,
                        title: 'Trang web chính thức',
                        onTap: () {
                          // TODO: Thay bằng URL trang web thực tế
                          _launchURL('https://herbscan.com');
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.star_outline,
                        title: 'Đánh giá ứng dụng',
                        onTap: () {
                          // TODO: Mở store để đánh giá
                          // _launchURL('https://play.google.com/store/apps/details?id=...');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tính năng đang được phát triển'),
                              backgroundColor: AppColors.info,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              // Footer
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  '© 2025 Herb Scan. All rights reserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: 12.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.textPrimary,
              size: 24.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF181511),
                  fontSize: 16.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 1,
      color: const Color(0xFFF3F4F6),
    );
  }
}

