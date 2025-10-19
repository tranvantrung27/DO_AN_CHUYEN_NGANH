import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterFields extends StatefulWidget {
  final TextEditingController? usernameController;
  final TextEditingController? passwordController;
  final TextEditingController? confirmPasswordController;
  final Function(String)? onUsernameChanged;
  final Function(String)? onPasswordChanged;
  final Function(String)? onConfirmPasswordChanged;
  final Function(bool)? onAuthTypeChanged;
  final bool hasUsernameError;
  final bool hasPasswordError;
  final bool hasConfirmPasswordError;
  final bool isEmailAuth;

  const RegisterFields({
    super.key,
    this.usernameController,
    this.passwordController,
    this.confirmPasswordController,
    this.onUsernameChanged,
    this.onPasswordChanged,
    this.onConfirmPasswordChanged,
    this.onAuthTypeChanged,
    this.hasUsernameError = false,
    this.hasPasswordError = false,
    this.hasConfirmPasswordError = false,
    this.isEmailAuth = true,
  });

  @override
  State<RegisterFields> createState() => _RegisterFieldsState();
}

class _RegisterFieldsState extends State<RegisterFields> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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

  Widget _buildAuthTypeToggle() {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => widget.onAuthTypeChanged?.call(true),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: widget.isEmailAuth ? const Color(0xFF3AAF3D) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 18.r,
                      color: widget.isEmailAuth ? Colors.white : const Color(0xFF6B7280),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: widget.isEmailAuth ? Colors.white : const Color(0xFF6B7280),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => widget.onAuthTypeChanged?.call(false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: !widget.isEmailAuth ? const Color(0xFF3AAF3D) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 18.r,
                      color: !widget.isEmailAuth ? Colors.white : const Color(0xFF6B7280),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Số điện thoại',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: !widget.isEmailAuth ? Colors.white : const Color(0xFF6B7280),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Auth type toggle
        _buildAuthTypeToggle(),
        
        // Username field
        _label(widget.isEmailAuth ? 'Email' : 'Số điện thoại'),
        SizedBox(height: 10.h),
        TextField(
          controller: widget.usernameController,
          textInputAction: TextInputAction.next,
          keyboardType: widget.isEmailAuth ? TextInputType.emailAddress : TextInputType.phone,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15.sp,
            color: const Color(0xFF2D2D2D),
            fontWeight: FontWeight.w400,
          ),
          decoration: _decoration(
            widget.isEmailAuth ? 'Nhập email của bạn' : 'Nhập số điện thoại',
            hasError: widget.hasUsernameError,
          ),
          onChanged: widget.onUsernameChanged,
        ),
        
        SizedBox(height: 18.h),
        
        // Mật khẩu
        _label('Mật khẩu'),
        SizedBox(height: 10.h),
        TextField(
          controller: widget.passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
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
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
        
        SizedBox(height: 18.h),
        
        // Nhập lại mật khẩu
        _label('Nhập lại mật khẩu'),
        SizedBox(height: 10.h),
        TextField(
          controller: widget.confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15.sp,
            color: const Color(0xFF2D2D2D),
            fontWeight: FontWeight.w400,
          ),
          decoration: _decoration(
            'Nhập lại mật khẩu',
            hasError: widget.hasConfirmPasswordError,
            suffix: IconButton(
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
          onChanged: widget.onConfirmPasswordChanged,
        ),
      ],
    );
  }
}
