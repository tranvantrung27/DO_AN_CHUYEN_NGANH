import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:card_loading/card_loading.dart';
import 'package:flutter_svg/flutter_svg.dart';


class ArticleCard extends StatelessWidget {
  final String imageUrl;
  final String dateText; // e.g., "Thứ hai, 15/9/2025, 13:33 (GMT+7)"
  final String title;
  final String subtitle; // Tiêu đề phụ
  final String sourceName; // e.g., "VnExpress"
  final String sourceAvatarUrl;
  final String timeAgo; // e.g., "4h ago"
  final VoidCallback? onTap;
  final bool isLoading;
  final bool showDateOnTop;

  // Chiều cao cố định cho card để đảm bảo tất cả card có cùng chiều cao
  static const double cardHeight = 140.0;

  const ArticleCard({
    super.key,
    required this.imageUrl,
    required this.dateText,
    required this.title,
    this.subtitle = '',
    required this.sourceName,
    required this.sourceAvatarUrl,
    required this.timeAgo,
    this.onTap,
    this.isLoading = false,
    this.showDateOnTop = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: cardHeight.h,
        padding: EdgeInsets.all(8.w),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardLoading(
              height: 96.w,
              width: 96.w,
              borderRadius: BorderRadius.circular(6.r),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardLoading(height: 14.h, width: 200.w, borderRadius: BorderRadius.circular(4.r)),
                  SizedBox(height: 6.h),
                  CardLoading(height: 18.h, width: double.infinity, borderRadius: BorderRadius.circular(4.r)),
                  SizedBox(height: 6.h),
                  CardLoading(height: 18.h, width: 220.w, borderRadius: BorderRadius.circular(4.r)),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      CardLoading(height: 20.w, width: 20.w, borderRadius: BorderRadius.circular(999)),
                      SizedBox(width: 6.w),
                      CardLoading(height: 14.h, width: 80.w, borderRadius: BorderRadius.circular(4.r)),
                      SizedBox(width: 12.w),
                      CardLoading(height: 14.h, width: 50.w, borderRadius: BorderRadius.circular(4.r)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        height: cardHeight.h,
        padding: EdgeInsets.all(8.w),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: SizedBox(
                width: 96.w,
                height: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return CardLoading(
                      height: double.infinity,
                      borderRadius: BorderRadius.circular(6.r),
                    );
                  },
                  errorBuilder: (_, __, ___) => CardLoading(
                    height: double.infinity,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // Right content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dòng 1: Thời gian
                  if (dateText.isNotEmpty)
                    Text(
                      dateText,
                      style: TextStyle(
                        color: const Color(0xFF4E4B66),
                        fontSize: 13.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                        letterSpacing: 0.12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 4.h),
                  // Dòng 2: Tiêu đề chính - có thể nhiều dòng, hiển thị "..." khi dài
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 2, // Giảm từ 3 xuống 2 để tránh overflow
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                        letterSpacing: 0.12,
                      ),
                    ),
                  ),
                  // Dòng 3: Tiêu đề phụ (chỉ hiển thị nếu có)
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF4E4B66),
                        fontSize: 14.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                        letterSpacing: 0.12,
                      ),
                    ),
                  ],
                  // Spacer để đẩy phần dưới xuống
                  const Spacer(),
                  // Dòng 4: Logo | Thời gian đăng
                  Row(
                    children: [
                      // Logo (chỉ hiển thị nếu có sourceAvatarUrl - trang tin tức)
                      if (sourceAvatarUrl.isNotEmpty) ...[
                        SizedBox(
                          height: 18.h,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 72.w,
                                height: 18.h,
                                child: sourceAvatarUrl.endsWith('.svg')
                                    ? SvgPicture.network(
                                        sourceAvatarUrl,
                                        fit: BoxFit.contain,
                                      )
                                    : Image.network(
                                        sourceAvatarUrl,
                                        fit: BoxFit.contain,
                                        loadingBuilder: (context, child, progress) {
                                          if (progress == null) return child;
                                          return CardLoading(
                                            height: 18.h,
                                            width: 72.w,
                                            borderRadius: BorderRadius.circular(4.r),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Thời gian đăng (hiển thị nếu có timeAgo và không có logo - trang các bệnh và sống khỏe)
                      if (timeAgo.isNotEmpty && sourceAvatarUrl.isEmpty)
                        Text(
                          timeAgo,
                          style: TextStyle(
                            color: const Color(0xFF4E4B66),
                            fontSize: 13.sp,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                            letterSpacing: 0.12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


