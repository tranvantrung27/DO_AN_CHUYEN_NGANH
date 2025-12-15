import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../constants/app_colors.dart';
import 'app_info/index.dart';

class UsageGuideScreen extends StatefulWidget {
  const UsageGuideScreen({super.key});

  @override
  State<UsageGuideScreen> createState() => _UsageGuideScreenState();
}

class _UsageGuideScreenState extends State<UsageGuideScreen> {
  int? _expandedFaqIndex;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'Làm cách nào để bắt đầu?',
      'answer': 'Để bắt đầu sử dụng ứng dụng, bạn cần đăng ký tài khoản hoặc đăng nhập. Sau đó, bạn có thể sử dụng các tính năng như quét ảnh, xem bài viết, tìm kiếm và lưu bài viết yêu thích.',
    },
    {
      'question': 'Làm thế nào để đặt lại mật khẩu?',
      'answer': 'Bạn có thể đặt lại mật khẩu bằng cách vào màn hình "Thông tin cá nhân" trong phần Cài đặt, sau đó chọn "Đổi mật khẩu" và làm theo hướng dẫn.',
    },
    {
      'question': 'Ứng dụng có miễn phí không?',
      'answer': 'Có, ứng dụng hoàn toàn miễn phí. Bạn có thể sử dụng tất cả các tính năng mà không cần trả phí.',
    },
  ];

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
          'Cách sử dụng',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.56,
            letterSpacing: -0.27,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CÂU HỎI THƯỜNG GẶP
              _buildSectionHeader('CÂU HỎI THƯỜNG GẶP'),
              SizedBox(height: 16.h),
              _buildFaqSection(),
              SizedBox(height: 24.h),
              // THÔNG TIN KHÁC
              _buildSectionHeader('THÔNG TIN KHÁC'),
              SizedBox(height: 16.h),
              _buildOtherInfoSection(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF6B7280),
          fontSize: 16.sp,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          height: 1.50,
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppColors.backgroundWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_faqs.length, (index) {
          final isExpanded = _expandedFaqIndex == index;
          final isLast = index == _faqs.length - 1;
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _expandedFaqIndex = isExpanded ? null : index;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          _faqs[index]['question']!,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                        size: 24.sp,
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
                  child: Text(
                    _faqs[index]['answer']!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ),
              if (!isLast)
                Container(
                  width: double.infinity,
                  height: 1,
                  color: const Color(0xFFE5E5EA),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOtherInfoSection() {
    final otherInfoItems = [
      {
        'title': 'Gửi phản hồi',
        'icon': Icons.chat_bubble_outline,
        'screen': const FeedbackScreen(),
      },
      {
        'title': 'Thông tin giới thiệu',
        'icon': Icons.info_outline,
        'screen': const AboutScreen(),
      },
      {
        'title': 'Chính sách bảo mật',
        'icon': Icons.shield_outlined,
        'screen': const PrivacyPolicyScreen(),
      },
      {
        'title': 'Điều khoản & Điều kiện',
        'icon': Icons.description_outlined,
        'screen': const TermsConditionsScreen(),
      },
    ];

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppColors.backgroundWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(otherInfoItems.length, (index) {
          final isLast = index == otherInfoItems.length - 1;
          final item = otherInfoItems[index];

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => item['screen'] as Widget,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            color: AppColors.textSecondary,
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.textSecondary,
                        size: 16.sp,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: double.infinity,
                  height: 1,
                  color: const Color(0xFFE5E5EA),
                ),
            ],
          );
        }),
      ),
    );
  }
}

