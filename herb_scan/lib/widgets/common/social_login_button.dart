import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Social login button widget
class SocialLoginButton extends StatelessWidget {
  /// Text hiển thị trên button
  final String text;
  
  /// Icon path (SVG hoặc IconData)
  final dynamic icon;
  
  /// Callback khi button được nhấn
  final VoidCallback? onPressed;
  
  /// Background color
  final Color backgroundColor;
  
  /// Text color
  final Color textColor;
  
  /// Border color
  final Color borderColor;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.backgroundColor = Colors.white,
    this.textColor = const Color(0xFF101522),
    this.borderColor = const Color(0xFFE5E7EB),
  });

  /// Factory cho Google login
  factory SocialLoginButton.google({
    Key? key,
    VoidCallback? onPressed,
  }) {
    return SocialLoginButton(
      key: key,
      text: 'Đăng nhập bằng Google',
      icon: 'assets/icons/google.svg',
      onPressed: onPressed,
    );
  }

  /// Factory cho Apple login
  factory SocialLoginButton.apple({
    Key? key,
    VoidCallback? onPressed,
  }) {
    return SocialLoginButton(
      key: key,
      text: 'Đăng nhập bằng Apple',
      icon: 'assets/icons/apple.svg',
      onPressed: onPressed,
    );
  }

  /// Factory cho Facebook login
  factory SocialLoginButton.facebook({
    Key? key,
    VoidCallback? onPressed,
  }) {
    return SocialLoginButton(
      key: key,
      text: 'Đăng nhập bằng Facebook',
      icon: 'assets/icons/facebook.svg',
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 56.h,
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: borderColor,
            ),
            borderRadius: BorderRadius.circular(32.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            _buildIcon(),
            
            SizedBox(width: 12.w),
            
            // Text
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 16.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1.50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (icon is String) {
      // SVG icon
      return SvgPicture.asset(
        icon,
        width: 20.r,
        height: 20.r,
      );
    } else if (icon is IconData) {
      // Flutter icon
      return Icon(
        icon,
        size: 20.r,
        color: textColor,
      );
    } else {
      return SizedBox(width: 20.r, height: 20.r);
    }
  }
}
