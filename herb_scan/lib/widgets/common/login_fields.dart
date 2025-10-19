import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginFields extends StatefulWidget {
  final TextEditingController? usernameController;
  final TextEditingController? passwordController;
  final Function(String)? onUsernameChanged;
  final Function(String)? onPasswordChanged;
  final bool hasUsernameError;
  final bool hasPasswordError;

  const LoginFields({
    super.key,
    this.usernameController,
    this.passwordController,
    this.onUsernameChanged,
    this.onPasswordChanged,
    this.hasUsernameError = false,
    this.hasPasswordError = false,
  });

  @override
  State<LoginFields> createState() => _LoginFieldsState();
}

class _LoginFieldsState extends State<LoginFields> {
  bool _obscure = true;

  // màu gần giống screenshot
  static const Color kErrorBorder = Color(0xFFC20052); // viền lỗi

  InputDecoration _decoration(String hint, {Widget? suffix, bool hasError = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 15.sp,
        color: const Color(0xFF9CA3AF),
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.r),
        borderSide: BorderSide(
          color: hasError ? kErrorBorder : const Color(0xFFE5E7EB), 
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.r),
        borderSide: BorderSide(
          color: hasError ? kErrorBorder : const Color(0xFF3AAF3D), 
          width: 1.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.r),
        borderSide: const BorderSide(color: kErrorBorder, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.r),
        borderSide: const BorderSide(color: kErrorBorder, width: 1.0),
      ),
      suffixIcon: suffix,
    );
  }

  Widget _label(String text) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 15.sp,
          color: const Color(0xFF2D2D2D),
          height: 1.3,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(text: text),
          const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Tên đăng nhập'),
        SizedBox(height: 10.h),
        TextField(
          controller: widget.usernameController,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15.sp,
            color: const Color(0xFF2D2D2D),
            fontWeight: FontWeight.w400,
          ),
          decoration: _decoration(
            'Nhập số điện thoại hoặc email',
            hasError: widget.hasUsernameError,
          ),
          onChanged: widget.onUsernameChanged,
        ),
        SizedBox(height: 18.h),
        _label('Mật khẩu'),
        SizedBox(height: 10.h),
        TextField(
          controller: widget.passwordController,
          obscureText: _obscure,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15.sp,
            color: const Color(0xFF2D2D2D),
            fontWeight: FontWeight.w400,
          ),
          decoration: _decoration(
            'Nhập mật khẩu',
            hasError: widget.hasPasswordError,
            suffix: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF6B7280),
                size: 22.r,
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: 44.w,
                minHeight: 44.h,
              ),
            ),
          ),
          onChanged: widget.onPasswordChanged,
        ),
      ],
    );
  }
}
