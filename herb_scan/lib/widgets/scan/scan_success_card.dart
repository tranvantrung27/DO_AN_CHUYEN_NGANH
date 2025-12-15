import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../../models/HerbLibrary/herb_article.dart';
import '../../models/scan/scan_result.dart';

/// Widget hiển thị card kết quả scan thành công
class ScanSuccessCard extends StatelessWidget {
  final HerbArticle herb;
  final ScanResult result;

  const ScanSuccessCard({
    super.key,
    required this.herb,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên lá
          Text(
            herb.name,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(height: 16.h),
          // Mô tả (chỉ hiển thị phần đầu, ngắn gọn)
          Text(
            'Mô tả',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _extractShortDescription(herb.description),
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 16.h),
          // Công dụng (chỉ hiển thị phần đầu, ngắn gọn)
          Text(
            'Công dụng',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _extractShortUsage(herb.description),
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Trích xuất mô tả ngắn (phần đầu, trước "Công dụng")
  String _extractShortDescription(String description) {
    final lowerDesc = description.toLowerCase();
    final usageIndex = lowerDesc.indexOf('công dụng:');
    if (usageIndex != -1) {
      return description.substring(0, usageIndex).trim();
    }
    // Nếu không tìm thấy, lấy 200 ký tự đầu
    if (description.length > 200) {
      return '${description.substring(0, 200)}...';
    }
    return description;
  }

  /// Trích xuất công dụng ngắn (chỉ phần công dụng, không có phương thuốc)
  String _extractShortUsage(String description) {
    final lowerDesc = description.toLowerCase();
    final usageIndex = lowerDesc.indexOf('công dụng:');
    if (usageIndex != -1) {
      final afterUsage = description.substring(usageIndex + 'công dụng:'.length);
      // Tìm dòng tiếp theo (Phương thuốc hoặc Dùng ngoài)
      final nextSectionIndex = afterUsage.toLowerCase().indexOf(RegExp(r'(phương thuốc|dùng ngoài)'));
      if (nextSectionIndex != -1) {
        return afterUsage.substring(0, nextSectionIndex).trim();
      }
      // Nếu không tìm thấy, lấy 150 ký tự đầu
      if (afterUsage.length > 150) {
        return '${afterUsage.substring(0, 150)}...';
      }
      return afterUsage.trim();
    }
    return 'Chưa có thông tin công dụng';
  }
}

