import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'herb_search_bar.dart';

/// Custom SliverPersistentHeaderDelegate cho header của Herb Library Screen
/// Header có khả năng co giãn mượt mà với text mờ dần và search bar sticky
class HerbLibraryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final double statusBarHeight;
  final VoidCallback? onSearchTap;

  HerbLibraryHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.statusBarHeight,
    this.onSearchTap,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Tính toán % đã cuộn (0.0 là chưa cuộn, 1.0 là cuộn hết cỡ)
    final progress = shrinkOffset / (maxExtent - minExtent);
    
    // Tính toán độ mờ của text: Cuộn càng nhiều thì text càng mờ nhanh
    final textOpacity = (1 - (progress * 1.5)).clamp(0.0, 1.0);

    return Container(
      // Container này trong suốt để thấy background cream của Scaffold ở các góc bo
      color: Colors.transparent, 
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Xanh lá: Vẫn cho phép giãn thoải mái (fill)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF3AAF3E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.r),
                bottomRight: Radius.circular(30.r),
              ),
            ),
          ),

          // 2. PHẦN SỬA ĐỔI: CONTENT WRAPPER
          // Thay vì thả trôi, ta gom nội dung vào 1 hộp có chiều cao CỐ ĐỊNH (maxHeight)
          // và ghim hộp này xuống ĐÁY (bottomCenter) của header.
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: maxHeight, // Chiều cao cố định, không bị giãn theo overscroll
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Text (Tiêu đề) - Vị trí tính theo hộp cố định này
                  Positioned(
                    top: statusBarHeight + 10.h, 
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: textOpacity,
                      child: Column(
                        children: [
                          Text(
                            'Bài thuốc dân gian',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Chăm sóc sức khỏe theo cách ông bà ta',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search Bar - Vị trí tính theo hộp cố định này
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 20.w, 
                        right: 20.w, 
                        bottom: 15.h 
                      ),
                      child: SizedBox(
                        height: 50.h,
                        child: HerbSearchBar(
                          onTap: onSearchTap ?? () {
                            // TODO: Navigate to search screen or show search dialog
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(HerbLibraryHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
           minHeight != oldDelegate.minHeight ||
           statusBarHeight != oldDelegate.statusBarHeight ||
           onSearchTap != oldDelegate.onSearchTap;
  }
}

