import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_loading/card_loading.dart';
import '../../constants/app_colors.dart';

/// Card hiển thị thảo dược/bài thuốc trong trang Kho thuốc
class HerbCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String? description; // Công dụng
  final String? category;
  final String? date; // e.g., "Jun 10, 2021"
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;
  final ValueChanged<String>? onCategoryTap; // Callback khi tap vào category
  final bool isLoading;
  final bool isBookmarked;

  const HerbCard({
    super.key,
    required this.imageUrl,
    required this.name,
    this.description,
    this.category,
    this.date,
    this.onTap,
    this.onBookmarkTap,
    this.onCategoryTap,
    this.isLoading = false,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 98.90.h,
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 7.h),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: const Color(0xFFE8F3F1),
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: CardLoading(
          height: 83.36.h,
          borderRadius: BorderRadius.circular(8.r),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: double.infinity,
        height: 98.90.h,
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 7.h),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: const Color(0xFFE8F3F1),
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hình ảnh thảo dược
            Container(
              width: 72.21.w,
              height: 83.36.h,
              decoration: ShapeDecoration(
                color: const Color(0xFFC4C4C4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 72.21.w,
                  height: 83.36.h,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 72.21.w,
                    height: 83.36.h,
                    color: const Color(0xFFC4C4C4),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 72.21.w,
                    height: 83.36.h,
                    color: const Color(0xFFC4C4C4),
                    child: Icon(
                      Icons.local_florist,
                      size: 30.w,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(width: 20.w),
            
            // Nội dung text
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF101623),
                        fontSize: 12.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        height: 1.33,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  // Description (Công dụng)
                  if (description != null && description!.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        '$description',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xBA2B2C34),
                          fontSize: 13.sp,
                          fontFamily: 'Overpass',
                          fontWeight: FontWeight.w500,
                          height: 1.46,
                        ),
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Date và Category ở dòng cuối
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Date bên trái
                      if (date != null && date!.isNotEmpty)
                        Text(
                          date!,
                          style: TextStyle(
                            color: const Color(0xFFADADAD),
                            fontSize: 9.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      
                      // Category bên phải (có thể tap để filter)
                      if (category != null && category!.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            onCategoryTap?.call(category!);
                          },
                          child: Text(
                            category!,
                            style: TextStyle(
                              color: const Color(0xFF199A8E),
                              fontSize: 9.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(width: 12.w),
            
            // Bookmark icon
            GestureDetector(
              onTap: onBookmarkTap,
              child: Container(
                width: 18.36.w,
                height: 21.19.h,
                child: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  size: 18.36.w,
                  color: const Color(0xFF199A8E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

