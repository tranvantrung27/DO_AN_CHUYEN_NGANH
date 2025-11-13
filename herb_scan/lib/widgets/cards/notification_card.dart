import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_loading/card_loading.dart';
import '../../utils/date_format_vn.dart';

class NotificationCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final DateTime? createdAt;
  final bool isRead; // Đã đọc chưa
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.createdAt,
    this.isRead = false,
    this.onTap,
  });

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final localTime = dateTime.toLocal();
    return formatVietnameseDate(localTime);
  }

  @override
  Widget build(BuildContext context) {
    // Opacity: 1.0 nếu chưa đọc, 0.5 nếu đã đọc
    final opacity = isRead ? 0.5 : 1.0;
    
    return Opacity(
      opacity: opacity,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.r),
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0x19000000),
                blurRadius: 10,
                offset: const Offset(0, 0),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh bên trái
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 96.w,
                height: 96.w,
                fit: BoxFit.cover,
                placeholder: (context, url) => CardLoading(
                  height: 96.w,
                  width: 96.w,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 96.w,
                  height: 96.w,
                  color: const Color(0xFFC4C4C4),
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 32,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Nội dung bên phải
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ngày giờ đăng (mép trái)
                  Text(
                    _formatDateTime(createdAt),
                    style: TextStyle(
                      color: const Color(0xFFA0A3BD),
                      fontSize: 12.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                      letterSpacing: 0.12,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Tiêu đề chính
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      height: 1.50,
                      letterSpacing: 0.12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  // Xem chi tiết (gạch chân)
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      'Xem chi tiết',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                        letterSpacing: 0.12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

