import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import '../../constants/index.dart';
import '../../widgets/index.dart';
import '../../widgets/common/otp_input_widget.dart';
import '../../mixins/index.dart';
import '../../services/index.dart';
import '../main_navigation_screen.dart';

/// Màn hình xác thực OTP
class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with LoadingMixin, ValidationMixin {
  
  final AuthService _authService = AuthService();
  int _countdown = 60; // 60 giây countdown
  Timer? _timer;
  String _currentOTP = '';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: AppLoadingOverlay(
        isLoading: isLoading,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 24.w,
          vertical: 16.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            _buildHeader(),

            SizedBox(height: 40.h),

            // OTP Input Fields
            _buildOTPFields(),

            SizedBox(height: 32.h),

            // Verify Button
            _buildVerifyButton(),

            SizedBox(height: 24.h),

            // Resend OTP
            _buildResendOTP(),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isTestMode = widget.verificationId == 'test_verification_id_123456';
    final isMockMode = widget.verificationId.startsWith('mock_verification_');
    
    return Column(
      children: [
        Text(
          'Xác thực số điện thoại',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF4E4B66),
            fontSize: 32.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            height: 1.5,
            letterSpacing: 0.12,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Chúng tôi đã gửi mã xác thực đến\n${widget.phoneNumber}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF4E4B66),
            fontSize: 16.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            height: 1.5,
            letterSpacing: 0.12,
          ),
        ),
        if (isTestMode || isMockMode) ...[
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFF59E0B), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFFF59E0B),
                      size: 20.r,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        isMockMode ? 'Mock Mode' : 'Development Mode',
                        style: TextStyle(
                          color: const Color(0xFF92400E),
                          fontSize: 14.sp,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'Nhập mã OTP: 123456',
                  style: TextStyle(
                    color: const Color(0xFF92400E),
                    fontSize: 14.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  isMockMode 
                    ? 'Mock mode: Hỗ trợ tất cả số điện thoại'
                    : 'Test phones: 0123456789, 0987654321',
                  style: TextStyle(
                    color: const Color(0xFF92400E),
                    fontSize: 12.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOTPFields() {
    return OTPInputWidget(
      length: 6,
      onCompleted: (otp) {
        _currentOTP = otp;
        _handleVerifyOTP();
      },
      onChanged: (otp) {
        _currentOTP = otp;
      },
      hintText: '•',
    );
  }

  Widget _buildVerifyButton() {
    return AuthButton(
      text: 'Xác thực',
      onPressed: _handleVerifyOTP,
      isLoading: isLoading,
    );
  }

  Widget _buildResendOTP() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Nút quay lại
        TextButton(
          onPressed: _handleGoBack,
          child: Text(
            'Quay lại',
            style: TextStyle(
              color: const Color(0xFF6B7280),
              fontSize: 14.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ),
        
        // Countdown hoặc nút gửi lại
        if (_countdown > 0)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Gửi lại mã sau ',
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: 14.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                TextSpan(
                  text: '${_countdown}s',
                  style: TextStyle(
                    color: const Color(0xFFC20052),
                    fontSize: 14.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          )
        else
          TextButton(
            onPressed: _handleResendOTP,
            child: Text(
              'Gửi lại mã',
              style: TextStyle(
                color: const Color(0xFF3AAF3D),
                fontSize: 14.sp,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
      ],
    );
  }

  // Event handlers
  void _handleGoBack() {
    Navigator.pop(context);
  }

  void _handleVerifyOTP() async {
    if (_currentOTP.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ 6 số OTP')),
      );
      return;
    }

    await withLoadingAndErrorHandling(() async {
      final result = await _authService.verifyPhoneOTP(
        verificationId: widget.verificationId,
        otp: _currentOTP,
        displayName: widget.phoneNumber,
      );
      
      if (result.isSuccess && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      } else if (result.errorMessage != null) {
        throw Exception(result.errorMessage);
      }
    }, 
    loadingMessage: 'Đang xác thực...',
    errorMessage: 'Xác thực OTP thất bại',
    );
  }

  void _handleResendOTP() async {
    await withLoadingAndErrorHandling(() async {
      final result = await _authService.sendPhoneOTP(widget.phoneNumber);
      
      if (result.isSuccess) {
        // Reset countdown
        setState(() {
          _countdown = 60;
        });
        _startCountdown();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mã OTP đã được gửi lại')),
        );
      } else if (result.errorMessage != null) {
        throw Exception(result.errorMessage);
      }
    },
    loadingMessage: 'Đang gửi lại mã OTP...',
    errorMessage: 'Không thể gửi lại mã OTP',
    );
  }
}
