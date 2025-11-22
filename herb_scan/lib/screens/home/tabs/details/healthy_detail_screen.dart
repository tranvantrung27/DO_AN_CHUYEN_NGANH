import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../../../constants/app_colors.dart';
import '../../../../models/HealthyTab/healthy_article.dart';
import 'package:card_loading/card_loading.dart';

class HealthyDetailScreen extends StatelessWidget {
  final HealthyArticle article;

  const HealthyDetailScreen({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar với nút back
            SliverAppBar(
              backgroundColor: AppColors.backgroundCream,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                // Có thể thêm các action buttons ở đây (share, bookmark, etc.)
                SizedBox(width: 24.w),
              ],
            ),
            // Nội dung
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 21.h),
                    // Ảnh bài viết
                    _buildArticleImage(),
                    SizedBox(height: 16.h),
                    // Tiêu đề
                    _buildTitle(),
                    SizedBox(height: 16.h),
                    // Nội dung bài viết
                    _buildContent(),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleImage() {
    return Container(
      width: double.infinity,
      height: 248.h,
      decoration: ShapeDecoration(
        color: const Color(0xFFC4C4C4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.r),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.r),
        child: Image.network(
          article.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CardLoading(
                height: 248.h,
                width: double.infinity,
                borderRadius: BorderRadius.circular(6.r),
              ),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFC4C4C4),
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      article.title,
      style: TextStyle(
        color: Colors.black,
        fontSize: 24.sp,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
        height: 1.50,
        letterSpacing: 0.12,
      ),
    );
  }

  Widget _buildContent() {
    // Hiển thị nội dung từ Firebase
    if (article.content.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Text(
            'Chúng tôi sẽ cập nhật nội dung sớm nhất có thể',
            style: TextStyle(
              color: const Color(0xFF4E4B66),
              fontSize: 16.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );
    }

    // Sử dụng Markdown để hiển thị nội dung với formatting
    // Cho phép HTML tags như <u> cho underline
    return MarkdownBody(
      data: article.content,
      selectable: true, // Cho phép copy text
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          color: const Color(0xFF4E4B66),
          fontSize: 16.sp,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          height: 1.50,
          letterSpacing: 0.12,
        ),
        strong: TextStyle(
          color: const Color(0xFF4E4B66),
          fontSize: 16.sp,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
        ),
        em: TextStyle(
          color: const Color(0xFF4E4B66),
          fontSize: 16.sp,
          fontFamily: 'Poppins',
          fontStyle: FontStyle.italic,
        ),
        del: TextStyle(
          color: const Color(0xFF4E4B66),
          fontSize: 16.sp,
          fontFamily: 'Poppins',
          decoration: TextDecoration.lineThrough,
        ),
        h1: TextStyle(
          color: const Color(0xFF4E4B66),
          fontSize: 20.sp,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          height: 1.50,
        ),
        h2: TextStyle(
          color: const Color(0xFF4E4B66),
          fontSize: 18.sp,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          height: 1.50,
        ),
        h3: TextStyle(
          color: const Color(0xFF4E4B66),
          fontSize: 17.sp,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          height: 1.50,
        ),
      ),
    );
  }
}

