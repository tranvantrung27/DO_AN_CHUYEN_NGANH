import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../../models/HerbLibrary/herb_article.dart';
import 'package:card_loading/card_loading.dart';

/// Màn hình chi tiết cho kết quả scan
class ScanDetailScreen extends StatelessWidget {
  final HerbArticle herb;

  const ScanDetailScreen({
    super.key,
    required this.herb,
  });

  @override
  Widget build(BuildContext context) {
    // Parse dữ liệu từ description
    final parsedData = _parseHerbData(herb.description);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar với ảnh
          SliverAppBar(
            expandedHeight: 300.h,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.4),
                foregroundColor: Colors.white,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    herb.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return CardLoading(
                        height: 300.h,
                        width: double.infinity,
                        borderRadius: BorderRadius.zero,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey.shade300),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24.h,
                    left: 24.w,
                    right: 24.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          herb.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (parsedData.scientificName != null) ...[
                          SizedBox(height: 8.h),
                          Text(
                            parsedData.scientificName!,
                            style: TextStyle(
                              color: Colors.green.shade200,
                              fontSize: 18.sp,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Nội dung
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mô tả
                  _buildSectionHeader(
                    Icons.book_outlined,
                    'Mô tả',
                    AppColors.primaryGreen,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    parsedData.description,
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.6,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Công dụng
                  if (parsedData.benefits.isNotEmpty) ...[
                    _buildSectionHeader(
                      Icons.auto_awesome_outlined,
                      'Công dụng',
                      AppColors.primaryGreen,
                    ),
                    SizedBox(height: 16.h),
                    ...parsedData.benefits.asMap().entries.map((entry) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24.w,
                                height: 24.w,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    (entry.key + 1).toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    SizedBox(height: 32.h),
                  ],

                  // Phương thuốc & Cách dùng
                  if (parsedData.usage.isNotEmpty) ...[
                    _buildSectionHeader(
                      Icons.medication_outlined,
                      'Phương thuốc & Cách dùng',
                      AppColors.primaryGreen,
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGreen.withValues(alpha: 0.05),
                            Colors.teal.shade50,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.primaryGreen.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        parsedData.usage,
                        style: TextStyle(
                          fontSize: 16.sp,
                          height: 1.6,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],

                  // Lưu ý khi sử dụng
                  if (parsedData.precautions.isNotEmpty) ...[
                    _buildSectionHeader(
                      Icons.warning_amber_rounded,
                      'Lưu ý khi sử dụng',
                      Colors.amber.shade600,
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Column(
                        children: parsedData.precautions.map((precaution) => Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 20.sp,
                                    color: Colors.amber.shade600,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      precaution,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],

                  // Disclaimer
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '⚠️ Thông tin chỉ mang tính chất tham khảo. Vui lòng tham khảo ý kiến bác sĩ trước khi sử dụng.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, size: 24.sp, color: color),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// Parse dữ liệu từ description
  _ParsedHerbData _parseHerbData(String description) {
    final lines = description.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    String parsedDescription = '';
    List<String> benefits = [];
    String usage = '';
    List<String> precautions = [];
    String? scientificName;

    String currentSection = 'description';
    
    for (final line in lines) {
      final lowerLine = line.toLowerCase();
      
      // Tìm scientific name (thường có dấu ngoặc đơn hoặc in nghiêng)
      if (line.contains('(') && line.contains(')')) {
        final match = RegExp(r'\(([^)]+)\)').firstMatch(line);
        if (match != null) {
          scientificName = match.group(1);
        }
      }

      // Xác định section
      if (lowerLine.contains('công dụng:')) {
        currentSection = 'benefits';
        final afterColon = line.substring(line.indexOf(':') + 1).trim();
        if (afterColon.isNotEmpty) {
          // Tách các công dụng bằng dấu chấm
          benefits = afterColon
              .split(RegExp(r'[.。]'))
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
        continue;
      } else if (lowerLine.contains('phương thuốc') || lowerLine.contains('cách dùng')) {
        currentSection = 'usage';
        usage = line + '\n';
        continue;
      } else if (lowerLine.contains('lưu ý') || lowerLine.contains('precautions')) {
        currentSection = 'precautions';
        continue;
      }

      // Thêm vào section tương ứng
      switch (currentSection) {
        case 'description':
          if (!lowerLine.contains('công dụng') && 
              !lowerLine.contains('phương thuốc') &&
              !lowerLine.contains('dùng ngoài')) {
            parsedDescription += (parsedDescription.isEmpty ? '' : '\n') + line;
          }
          break;
        case 'benefits':
          if (!lowerLine.contains('phương thuốc') && 
              !lowerLine.contains('dùng ngoài')) {
            // Nếu chưa có benefits, thử parse từ dòng này
            if (benefits.isEmpty) {
              benefits = line
                  .split(RegExp(r'[.。]'))
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
            }
          } else {
            currentSection = 'usage';
            usage = line + '\n';
          }
          break;
        case 'usage':
          usage += line + '\n';
          break;
        case 'precautions':
          if (line.startsWith('-') || line.startsWith('•')) {
            precautions.add(line.substring(1).trim());
          } else {
            precautions.add(line);
          }
          break;
      }
    }

    // Nếu không parse được benefits, thử tìm trong description
    if (benefits.isEmpty) {
      final usageMatch = RegExp(r'công dụng:\s*(.+?)(?:\n|phương thuốc|dùng ngoài)', 
          caseSensitive: false, dotAll: true).firstMatch(description);
      if (usageMatch != null) {
        benefits = usageMatch.group(1)!
            .split(RegExp(r'[.。]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    // Nếu không parse được usage, lấy phần sau "Phương thuốc"
    if (usage.isEmpty) {
      final usageIndex = description.toLowerCase().indexOf('phương thuốc');
      if (usageIndex != -1) {
        usage = description.substring(usageIndex).trim();
      }
    }

    return _ParsedHerbData(
      description: parsedDescription.isEmpty ? description.split('\n').first : parsedDescription,
      benefits: benefits,
      usage: usage.trim(),
      precautions: precautions,
      scientificName: scientificName,
    );
  }
}

/// Class để lưu dữ liệu đã parse
class _ParsedHerbData {
  final String description;
  final List<String> benefits;
  final String usage;
  final List<String> precautions;
  final String? scientificName;

  _ParsedHerbData({
    required this.description,
    required this.benefits,
    required this.usage,
    required this.precautions,
    this.scientificName,
  });
}

