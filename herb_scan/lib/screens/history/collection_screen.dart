import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: Container(
              width: 330.w,
              height: 330.h,
              child: Image.asset(
                "assets/icons/collection.png",
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading collection image: $error');
                  return Container(
                    width: 330.w,
                    height: 330.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.collections_bookmark,
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
              'Bộ sưu tập lá thuốc trống rỗng',
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
              'Hãy ghi lại những lá thuốc quý giá \nvà hữu ích cho bạn!',
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
