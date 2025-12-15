import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../constants/app_colors.dart';
import '../../services/scan/scan_service.dart';
import '../../widgets/scan/index.dart';
import 'scan_result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final ScanService _scanService = ScanService();
  ScanLoadingStage _loadingStage = ScanLoadingStage.none;
  String? _previewImagePath;

  Future<void> _captureAndScan() async {
    // Kiểm tra quyền camera
    final cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      final result = await Permission.camera.request();
      if (!result.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cần quyền truy cập camera để quét lá cây'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
    }

    try {
      // Mở camera của máy để chụp ảnh
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      // Nếu người dùng hủy hoặc không chọn ảnh, không làm gì
      if (image == null) return;

      // Bắt đầu quá trình scan
      await _startScanning(image.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chụp ảnh: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) return;

      // Bắt đầu quá trình scan
      await _startScanning(image.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _startScanning(String imagePath) async {
    try {
      // Hiển thị ảnh và bắt đầu loading
      setState(() {
        _previewImagePath = imagePath;
        _loadingStage = ScanLoadingStage.analyzing;
      });

      // Stage 1: AI đang phân tích (tăng thời gian lên 4 giây)
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return;

      // Stage 2: Đang nhận dạng
      setState(() {
        _loadingStage = ScanLoadingStage.identifying;
      });

      // Đợi thêm 3 giây để hiển thị hiệu ứng đánh chữ và 3 chấm
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      // Thực hiện scan thực tế
      final result = await _scanService.scanImage(imagePath);

      if (!mounted) return;

      // Điều hướng đến màn hình kết quả
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanResultScreen(result: result),
        ),
      );

      // Reset sau khi quay lại
      if (mounted) {
        setState(() {
          _loadingStage = ScanLoadingStage.none;
          _previewImagePath = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingStage = ScanLoadingStage.none;
          _previewImagePath = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi quét: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              const ScanHeader(),
              SizedBox(height: 40.h),
              ScanPreviewArea(
                loadingStage: _loadingStage,
                previewImagePath: _previewImagePath,
              ),
              SizedBox(height: 30.h),
              ScanActionButtons(
                isScanning: _loadingStage != ScanLoadingStage.none,
                onGalleryTap: _pickFromGallery,
                onCaptureTap: _captureAndScan,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
