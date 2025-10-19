import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/index.dart';
import '../../widgets/index.dart';
import '../../services/auth_service.dart';
import 'reset_password_otp_screen.dart';

class ForgotPasswordSMSScreen extends StatefulWidget {
  const ForgotPasswordSMSScreen({super.key});

  @override
  State<ForgotPasswordSMSScreen> createState() => _ForgotPasswordSMSScreenState();
}

class _ForgotPasswordSMSScreenState extends State<ForgotPasswordSMSScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: Column(
          children: [
            // Main Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 24.w,
                        height: 24.h,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/comback.svg',
                            width: 24.w,
                            height: 24.h,
                            colorFilter: ColorFilter.mode(
                              AppColors.textSecondary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Title and Description
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quên mật khẩu?',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 32.sp,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            height: 1.50,
                            letterSpacing: 0.12,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          'Đừng lo lắng! Điều đó vẫn xảy ra.\nVui lòng nhập số điện thoại liên kết với tài khoản\ncủa bạn.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16.sp,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                            letterSpacing: 0.12,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Phone Input Section
                    Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nhập số điện thoại của bạn:',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                              letterSpacing: 0.12,
                            ),
                          ),
                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 10.h),
                    
                    // Phone Input Field
                    TextField(
                      controller: _phoneController,
                      focusNode: _phoneFocusNode,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15.sp,
                        color: const Color(0xFF2D2D2D),
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: '+84-334-xxx-xxx',
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
                            color: const Color(0xFFE5E7EB), 
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.r),
                          borderSide: BorderSide(
                            color: const Color(0xFF3AAF3D), 
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Continue Button
            ContinueButton(
              text: 'Tiếp tục',
              onPressed: _handleContinue,
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinue() async {
    final phone = _phoneController.text.trim();
    
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập số điện thoại'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Validate phone number format
    if (!_isValidPhoneNumber(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Số điện thoại không đúng định dạng. Vui lòng nhập lại số hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Format phone number to +84 format
    String formattedPhone = phone;
    if (phone.startsWith('0')) {
      formattedPhone = '+84${phone.substring(1)}';
    } else if (!phone.startsWith('+84')) {
      formattedPhone = '+84$phone';
    }
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // Kiểm tra số điện thoại đã đăng ký chưa
      final checkResult = await _authService.isPhoneNumberRegisteredForReset(formattedPhone);
      
      // Hide loading
      Navigator.pop(context);
      
      if (checkResult.isSuccess) {
        // Số điện thoại đã đăng ký, gửi SMS và chuyển đến màn hình OTP
        final smsResult = await _authService.resetPasswordBySMS(formattedPhone);
        
        if (smsResult.isSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordOTPScreen(
                phoneNumber: formattedPhone,
                verificationId: smsResult.verificationId ?? 'fallback_verification_id',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể gửi SMS: ${smsResult.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Số điện thoại chưa đăng ký, hiển thị thông báo
        _showPhoneNotRegisteredDialog(formattedPhone);
      }
    } catch (e) {
      // Hide loading
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isValidPhoneNumber(String phone) {
    // Remove all non-digit characters
    String digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's a valid Vietnamese phone number
    // Vietnamese mobile numbers: 10 digits starting with 0, then 3, 5, 7, 8, 9
    if (digitsOnly.length == 10 && digitsOnly.startsWith('0')) {
      String secondDigit = digitsOnly[1];
      return ['3', '5', '7', '8', '9'].contains(secondDigit);
    }
    
    // Check if it's already in +84 format
    if (digitsOnly.length == 11 && digitsOnly.startsWith('84')) {
      String thirdDigit = digitsOnly[2];
      return ['3', '5', '7', '8', '9'].contains(thirdDigit);
    }
    
    return false;
  }

  void _showPhoneNotRegisteredDialog(String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.orange,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Thông báo',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        content: Text(
          'Số điện thoại $phoneNumber chưa được đăng ký.\nVui lòng đăng ký tài khoản trước.',
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Poppins',
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              Navigator.pop(context); // Quay về màn hình trước
            },
            child: Text(
              'Đóng',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
