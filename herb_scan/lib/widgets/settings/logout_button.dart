import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget nút đăng xuất
class LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const LogoutButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      decoration: ShapeDecoration(
        color: const Color(0xFF3AAF3D),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Colors.black.withOpacity(0.15),
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            'Đăng xuất',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.sp,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              letterSpacing: -0.17,
            ),
          ),
        ),
      ),
    );
  }
}

