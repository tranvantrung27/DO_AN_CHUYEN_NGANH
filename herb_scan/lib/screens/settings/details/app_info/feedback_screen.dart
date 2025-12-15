import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../constants/app_colors.dart';
import '../../../../services/feedback/feedback_service.dart';
import 'feedback_history_screen.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  final FeedbackService _feedbackService = FeedbackService();
  final List<XFile> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
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

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Chuyển XFile sang File
      List<File> imageFiles = _selectedImages
          .map((xFile) => File(xFile.path))
          .toList();

      // Gửi feedback
      final result = await _feedbackService.submitFeedback(
        content: _feedbackController.text.trim(),
        images: imageFiles.isNotEmpty ? imageFiles : null,
      );

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Cảm ơn bạn đã gửi phản hồi!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        _feedbackController.clear();
        if (mounted) {
          setState(() {
            _selectedImages.clear();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Lỗi khi gửi phản hồi'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi gửi phản hồi: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  bool get _canSubmit {
    return _feedbackController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCream,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            alignment: Alignment.center,
            child: Text(
              'Huỷ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.warningLight,
                fontSize: 16.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Gửi phản hồi',
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: 18.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.56,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.history,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FeedbackHistoryScreen(),
                ),
              );
            },
            tooltip: 'Lịch sử phản hồi',
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phản hồi của bạn
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Text(
                              'Phản hồi của bạn',
                              style: TextStyle(
                                color: AppColors.textPrimaryMedium,
                                fontSize: 16.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1.50,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            constraints: BoxConstraints(minHeight: 192.h),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundWhite,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                width: 1,
                                color: AppColors.borderGrey,
                              ),
                            ),
                            child: TextFormField(
                              controller: _feedbackController,
                              maxLines: null,
                              minLines: 8,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Vui lòng mô tả chi tiết vấn đề hoặc góp ý của \nbạn...',
                                hintStyle: TextStyle(
                                  color: AppColors.textPlaceholder,
                                  fontSize: 16.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.50,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.all(17.w),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Vui lòng nhập phản hồi';
                                }
                                return null;
                              },
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      // Thêm ảnh chụp màn hình
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: _pickImages,
                            child: Container(
                              width: double.infinity,
                              height: 48.h,
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundGreyLight,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: AppColors.warningLight,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Thêm ảnh chụp màn hình',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.warningLight,
                                      fontSize: 16.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      height: 1.50,
                                      letterSpacing: 0.24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Hiển thị ảnh đã chọn
                          if (_selectedImages.isNotEmpty) ...[
                            SizedBox(height: 16.h),
                            Wrap(
                              spacing: 12.w,
                              runSpacing: 12.h,
                              children: List.generate(
                                _selectedImages.length,
                                (index) => _buildImagePreview(index),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Nút Gửi
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              decoration: BoxDecoration(
                color: AppColors.backgroundCream,
              ),
              child: Opacity(
                opacity: (_canSubmit && !_isSubmitting) ? 1.0 : 0.3,
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: (_canSubmit && !_isSubmitting) ? _submitFeedback : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Gửi',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              height: 1.50,
                              letterSpacing: 0.24,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(int index) {
    return Stack(
      children: [
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            image: DecorationImage(
              image: FileImage(File(_selectedImages[index].path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: -6,
          top: -6,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: AppColors.overlayDark,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 14.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

