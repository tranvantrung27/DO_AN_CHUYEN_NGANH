import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../../services/scan/scan_service.dart';
import '../../widgets/scan/scan_loading_content.dart';
import 'scan_result_screen.dart';

/// Màn hình loading khi đang phân tích và nhận dạng
class ScanLoadingScreen extends StatefulWidget {
  final String imagePath;

  const ScanLoadingScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<ScanLoadingScreen> createState() => _ScanLoadingScreenState();
}

class _ScanLoadingScreenState extends State<ScanLoadingScreen> {
  final ScanService _scanService = ScanService();
  ScanLoadingStage _currentStage = ScanLoadingStage.analyzing;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  Future<void> _startScanning() async {
    try {
      // Stage 1: AI đang phân tích
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      setState(() {
        _currentStage = ScanLoadingStage.analyzing;
      });

      // Giả lập thời gian phân tích (sau này sẽ là thời gian load mô hình)
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Stage 2: Đang nhận dạng
      setState(() {
        _currentStage = ScanLoadingStage.identifying;
      });

      // Thực hiện scan thực tế
      final result = await _scanService.scanImage(widget.imagePath);

      if (!mounted) return;

      // Điều hướng đến màn hình kết quả
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ScanResultScreen(result: result),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });

        // Hiển thị lỗi và quay lại sau 2 giây
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: _errorMessage != null
              ? _buildErrorState()
              : _buildLoadingState(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    switch (_currentStage) {
      case ScanLoadingStage.analyzing:
        return ScanLoadingContent(
          title: 'AI đang phân tích',
          subtitle: 'Quá trình có thể mất vài giây\nvui lòng giữ ứng dụng mở',
        );
      case ScanLoadingStage.identifying:
        return ScanLoadingContent(
          title: 'Đang nhận dạng',
          subtitle: 'Đang xử lý hình ảnh...',
        );
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: AppColors.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Đã xảy ra lỗi',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _errorMessage ?? 'Vui lòng thử lại',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

enum ScanLoadingStage {
  analyzing, // AI đang phân tích
  identifying, // Đang nhận dạng
}

