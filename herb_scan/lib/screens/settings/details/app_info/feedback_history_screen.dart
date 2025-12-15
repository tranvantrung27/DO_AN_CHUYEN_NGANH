import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../constants/app_colors.dart';
import '../../../../services/feedback/feedback_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class FeedbackHistoryScreen extends StatefulWidget {
  const FeedbackHistoryScreen({super.key});

  @override
  State<FeedbackHistoryScreen> createState() => _FeedbackHistoryScreenState();
}

class _FeedbackHistoryScreenState extends State<FeedbackHistoryScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  bool _isLocaleInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    try {
      await initializeDateFormatting('vi', null);
      if (mounted) {
        setState(() {
          _isLocaleInitialized = true;
        });
      }
    } catch (e) {
      print('Lỗi khi khởi tạo locale: $e');
      // Nếu không khởi tạo được, vẫn hiển thị với format mặc định
      if (mounted) {
        setState(() {
          _isLocaleInitialized = true;
        });
      }
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'read':
        return 'Đã đọc';
      case 'replied':
        return 'Đã phản hồi';
      case 'resolved':
        return 'Đã giải quyết';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'read':
        return AppColors.info;
      case 'replied':
        return AppColors.success;
      case 'resolved':
        return AppColors.primaryGreen;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is Timestamp) {
      date = date.toDate();
    }
    if (date is DateTime) {
      // Nếu locale chưa khởi tạo, dùng format không cần locale
      if (!_isLocaleInitialized) {
        return DateFormat('dd/MM/yyyy HH:mm').format(date);
      }
      try {
        return DateFormat('dd/MM/yyyy HH:mm', 'vi').format(date);
      } catch (e) {
        // Fallback nếu có lỗi với locale
        return DateFormat('dd/MM/yyyy HH:mm').format(date);
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Lịch sử phản hồi',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.56,
            letterSpacing: -0.27,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _feedbackService.getUserFeedback(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Lỗi: ${snapshot.error}',
                  style: TextStyle(color: AppColors.error),
                ),
              );
            }

            final feedbackList = snapshot.data ?? [];

            if (feedbackList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.feedback_outlined,
                      size: 64.sp,
                      color: AppColors.textLight,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Chưa có phản hồi nào',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: feedbackList.length,
              itemBuilder: (context, index) {
                final feedback = feedbackList[index];
                final status = feedback['status'] ?? 'pending';
                final replyMessage = feedback['replyMessage'] as String?;

                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWhite,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      width: 1,
                      color: AppColors.borderLight,
                    ),
                  ),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatDate(feedback['createdAt']),
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4.r),
                                border: Border.all(
                                  color: _getStatusColor(status),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getStatusText(status),
                                style: TextStyle(
                                  color: _getStatusColor(status),
                                  fontSize: 12.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          feedback['content'] ?? '',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    children: [
                      // Hiển thị ảnh nếu có
                      if (feedback['imageUrls'] != null &&
                          (feedback['imageUrls'] as List).isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: (feedback['imageUrls'] as List)
                              .map<Widget>((url) => Container(
                                    width: 80.w,
                                    height: 80.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.r),
                                      image: DecorationImage(
                                        image: NetworkImage(url.toString()),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        SizedBox(height: 12.h),
                      ],
                      // Hiển thị phản hồi từ admin nếu có
                      if (replyMessage != null && replyMessage.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppColors.primaryGreen.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.reply,
                                    size: 16.sp,
                                    color: AppColors.primaryGreen,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Phản hồi từ admin',
                                    style: TextStyle(
                                      color: AppColors.primaryGreen,
                                      fontSize: 14.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (feedback['repliedAt'] != null) ...[
                                    Spacer(),
                                    Text(
                                      _formatDate(feedback['repliedAt']),
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12.sp,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                replyMessage,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (status == 'replied') ...[
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16.sp,
                                color: AppColors.info,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'Admin đã phản hồi phản hồi của bạn',
                                  style: TextStyle(
                                    color: AppColors.info,
                                    fontSize: 14.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

