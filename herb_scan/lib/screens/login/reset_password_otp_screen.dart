import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import '../../constants/index.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/otp_input_widget.dart';
import 'reset_password_screen.dart';

class ResetPasswordOTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  
  const ResetPasswordOTPScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<ResetPasswordOTPScreen> createState() => _ResetPasswordOTPScreenState();
}

class _ResetPasswordOTPScreenState extends State<ResetPasswordOTPScreen> {
  final AuthService _authService = AuthService();
  
  int _countdown = 60;
  Timer? _timer;
  bool _isResendEnabled = false;
  String _currentOTP = '';
  String _currentVerificationId = ''; // Lưu verification ID hiện tại

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId; // Khởi tạo với verification ID ban đầu
    _startCountdown();
    // Không gửi OTP lại khi init vì đã được gửi ở màn hình trước
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 60;
    _isResendEnabled = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _isResendEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  void _sendOTP() async {
    try {
      final result = await _authService.resetPasswordBySMS(widget.phoneNumber);
      if (result.isSuccess && result.verificationId != null) {
        // Cập nhật verification ID mới khi resend
        setState(() {
          _currentVerificationId = result.verificationId!;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã gửi mã OTP đến ${widget.phoneNumber}'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Có lỗi xảy ra'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleResendOTP() {
    _startCountdown();
    _sendOTP();
  }

  void _handleVerifyOTP() async {
    if (_currentOTP.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập đầy đủ 6 số OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
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
      // Verify OTP thực sự với verification ID hiện tại
      final verifyResult = await _authService.verifyOTPForPasswordReset(
        verificationId: _currentVerificationId,
        otp: _currentOTP,
      );

      // Hide loading
      Navigator.pop(context);

      if (verifyResult.isSuccess) {
        // Navigate to new password screen với OTP đã verify
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              phoneNumber: widget.phoneNumber,
              verificationId: _currentVerificationId,
              otp: _currentOTP, // Truyền OTP thực tế
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(verifyResult.errorMessage ?? 'Mã OTP không đúng. Vui lòng thử lại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Hide loading
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mã OTP không đúng. Vui lòng thử lại'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xác thực OTP',
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
                          'Vui lòng nhập mã OTP đã được gửi đến\n${widget.phoneNumber}',
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
                    
                    SizedBox(height: 40.h),
                    
                    // OTP Input Fields
                    OTPInputWidget(
                      length: 6,
                      onCompleted: (otp) {
                        _currentOTP = otp;
                        _handleVerifyOTP();
                      },
                      onChanged: (otp) {
                        _currentOTP = otp;
                      },
                      hintText: '•',
                    ),
                    
                    SizedBox(height: 40.h),
                    
                    // Resend OTP Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_isResendEnabled) ...[
                          Text(
                            'Gửi lại mã sau ${_countdown}s',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ] else ...[
                          TextButton(
                            onPressed: _handleResendOTP,
                            child: Text(
                              'Gửi lại mã OTP',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontSize: 14.sp,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Verify Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.backgroundCream,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _handleVerifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 13.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Xác thực',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                    letterSpacing: 0.12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
