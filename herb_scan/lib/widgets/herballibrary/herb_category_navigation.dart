import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/app_colors.dart';

/// Model cho category item
class HerbCategory {
  final String id;
  final String name;
  final String imageUrl;
  
  const HerbCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

/// Widget navigation danh mục cho trang Kho thuốc
/// Hiển thị danh sách các danh mục với scroll ngang
class HerbCategoryNavigation extends StatelessWidget {
  final List<HerbCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String>? onCategorySelected;
  
  const HerbCategoryNavigation({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final leftPadding = 10.w;
    final spacing = 11.w;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tính toán chính xác với constraints thực tế
        final availableWidth = constraints.maxWidth;
        // Sử dụng giá trị thực tế từ screenutil
        final itemWidth = 73.17.w;
        final totalItemWidth = (itemWidth * categories.length) + 
                              (spacing * (categories.length - 1)) + 
                              leftPadding;
        // Chỉ cho phép scroll nếu tổng width lớn hơn available width một chút (tolerance)
        final needsScroll = totalItemWidth > (availableWidth + 1);
        
        return Container(
          width: double.infinity,
          height: 120.h,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: leftPadding),
            physics: needsScroll 
                ? const ClampingScrollPhysics() // Tắt overscroll effect
                : const NeverScrollableScrollPhysics(),
            // Thêm để đảm bảo không scroll khi không cần
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
            itemCount: categories.length,
            separatorBuilder: (context, index) => SizedBox(width: spacing),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategoryId == category.id;
              
              return _CategoryItem(
                category: category,
                isSelected: isSelected,
                onTap: () => onCategorySelected?.call(category.id),
              );
            },
          ),
        );
      },
    );
  }
}

/// Widget cho mỗi category item
class _CategoryItem extends StatelessWidget {
  final HerbCategory category;
  final bool isSelected;
  final VoidCallback? onTap;
  
  const _CategoryItem({
    required this.category,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 73.17.w,
        height: 120.h,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(70.r),
          ),
          shadows: [
            BoxShadow(
              color: const Color(0x0C000000),
              blurRadius: 23,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hình ảnh oval
            ClipOval(
              child: category.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: category.imageUrl,
                      width: 54.88.w,
                      height: 54.88.w,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 54.88.w,
                        height: 54.88.w,
                        color: AppColors.borderLight,
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
                        width: 54.88.w,
                        height: 54.88.w,
                        color: AppColors.borderLight,
                        child: Icon(
                          Icons.local_florist,
                          size: 30.w,
                          color: AppColors.textLight,
                        ),
                      ),
                    )
                  : Container(
                      width: 54.88.w,
                      height: 54.88.w,
                      color: AppColors.borderLight,
                      child: Icon(
                        Icons.local_florist,
                        size: 30.w,
                        color: AppColors.textLight,
                      ),
                    ),
            ),
            
            SizedBox(height: 8.h),
            
            // Text tên danh mục
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xF2090F47),
                fontSize: 11.sp,
                fontFamily: 'Overpass',
                fontWeight: FontWeight.w300,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

