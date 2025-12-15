import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../../models/scan/scan_result.dart';
import '../../models/HerbLibrary/herb_article.dart';
import '../../services/HerbLibrary/herb_library_service.dart';
import '../../services/tts_service.dart';
import '../../widgets/scan/index.dart';
import 'scan_detail_screen.dart';
import '../chat/chat_ai_screen.dart';

class ScanResultScreen extends StatefulWidget {
  final ScanResult result;

  const ScanResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  List<HerbArticle> _relatedRecipes = [];
  bool _isLoadingRelated = true;
  final TtsService _ttsService = TtsService();
  String? _selectedBenefit;
  bool _hasSpoken = false;

  @override
  void initState() {
    super.initState();
    _loadRelatedRecipes();
    _speakIdentification();
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  /// 🔊 CẬP NHẬT 1: Phát âm thanh từ trường voice_summary trên Firebase
  Future<void> _speakIdentification() async {
    if (_hasSpoken || widget.result.identifiedHerb == null) return;
    
    await Future.delayed(const Duration(milliseconds: 500)); 
    
    final herb = widget.result.identifiedHerb!;
    
    if (mounted) {
      // Ưu tiên dùng voiceSummary từ Firebase, nếu không có thì fallback về tên cây
      String textToSpeak = herb.voiceSummary ?? "Đã nhận diện cây ${herb.name}";
      
      // Nếu voiceSummary rỗng (do chưa nhập liệu), có thể tạo câu default
      if (textToSpeak.trim().isEmpty) {
        textToSpeak = "Đã nhận diện cây ${herb.name}. Mời bạn chọn công dụng bên dưới để tìm hiểu thêm.";
      }
      
      await _ttsService.speak(textToSpeak);
      _hasSpoken = true;
    }
  }

  Future<void> _loadRelatedRecipes() async {
    if (widget.result.identifiedHerb == null) {
      setState(() {
        _isLoadingRelated = false;
      });
      return;
    }

    try {
      // Vẫn có thể giữ logic tìm bài thuốc liên quan theo tên cây
      final recipes = await HerbLibraryService.getRelatedRecipesByHerbName(
        widget.result.identifiedHerb!.name,
        "", // Không cần extract usage phức tạp nữa
        excludeId: widget.result.identifiedHerb!.id,
        limit: 5,
      );

      if (mounted) {
        setState(() {
          _relatedRecipes = recipes;
          _isLoadingRelated = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRelated = false;
        });
      }
    }
  }

  /// Xem chi tiết đầy đủ của cây thuốc
  /// Có thể được dùng trong tương lai khi cần nút "Xem chi tiết"
  // ignore: unused_element
  void _viewHerbDetails() {
    if (widget.result.identifiedHerb != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanDetailScreen(
            herb: widget.result.identifiedHerb!,
          ),
        ),
      );
    }
  }


  /// Xử lý khi người dùng chọn một công dụng
  void _onBenefitSelected(String benefit) {
    setState(() {
      _selectedBenefit = benefit;
    });
    
    // Tạo prompt cho Chat AI
    final herb = widget.result.identifiedHerb;
    if (herb == null) return;
    
    final herbName = herb.name;
    // Ví dụ: "Lá Trầu Không chữa vết thương như thế nào?"
    final prompt = '$herbName $benefit như thế nào?';
    
    // Mở màn hình Chat AI với thông tin cây thuốc và prompt đã điền sẵn
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatAiScreen(
          herb: herb,
          initialPrompt: prompt,
          imagePath: widget.result.imagePath, // Truyền ảnh người dùng đã chụp
        ),
      ),
    );
  }

  /// Parse scientific name từ description (fallback nếu Model chưa có)
  String? _parseScientificName(String description) {
    // Nếu trong Model đã có trường scientificName riêng thì dùng luôn: return herb.scientificName;
    // Nếu chưa có thì giữ lại regex này làm fallback
    final match = RegExp(r'\(([^)]+)\)').firstMatch(description);
    return match?.group(1);
  }

  /// Trích xuất mô tả ngắn để hiển thị (chỉ lấy phần đầu trước khi vào chi tiết)
  String _extractShortDescription(String description) {
    // Nếu có voiceSummary thì hiển thị voiceSummary làm mô tả ngắn luôn cho đồng bộ
    if (widget.result.identifiedHerb?.voiceSummary != null && 
        widget.result.identifiedHerb!.voiceSummary!.isNotEmpty) {
      return widget.result.identifiedHerb!.voiceSummary!;
    }
    
    // Fallback logic cũ
    final lowerDesc = description.toLowerCase();
    final usageIndex = lowerDesc.indexOf('công dụng:');
    if (usageIndex != -1) {
      return description.substring(0, usageIndex).trim();
    }
    if (description.length > 150) {
      return '${description.substring(0, 150)}...';
    }
    return description;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.result.isSuccess || widget.result.identifiedHerb == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundCream,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: ScanFailureCard(result: widget.result),
        ),
      );
    }

    final herb = widget.result.identifiedHerb!;
    // Ưu tiên lấy scientificName từ Model nếu bạn đã thêm trường này
    final scientificName = herb.scientificName ?? _parseScientificName(herb.description);

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kết quả quét',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SizedBox(height: 16.h),
            // Herb Card
            Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24.r),
                            ),
                            child: Stack(
                              children: [
                                // Hiển thị ảnh người dùng đã chụp/chọn
                                if (widget.result.imagePath != null)
                                  Image.file(
                                    File(widget.result.imagePath!),
                                    height: 200.h,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                          height: 200.h,
                                          color: Colors.grey.shade300,
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 48.sp,
                                            color: Colors.grey,
                                          ),
                                        ),
                                  )
                                else
                                  // Fallback nếu không có ảnh
                                  Image.network(
                                    herb.imageUrl,
                                    height: 200.h,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 200.h,
                                        color: Colors.grey.shade300,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                          height: 200.h,
                                          color: Colors.grey.shade300,
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 48.sp,
                                            color: Colors.grey,
                                          ),
                                        ),
                                  ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(24.w),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.8),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          herb.name,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (scientificName != null) ...[
                                          SizedBox(height: 4.h),
                                          Text(
                                            scientificName,
                                            style: TextStyle(
                                              color: Colors.green.shade100,
                                              fontSize: 16.sp,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(24.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Mô tả
                                Text(
                                  _extractShortDescription(herb.description),
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14.sp,
                                    height: 1.5,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 16.h),
                                // Nút Thêm vào bộ sưu tập
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                     
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Đã thêm ${herb.name} vào bộ sưu tập'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.bookmark_add_outlined, size: 20.sp),
                                    label: Text(
                                      'Thêm vào bộ sưu tập',
                                      style: TextStyle(fontSize: 16.sp),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primaryGreen,
                                      side: BorderSide(
                                        color: AppColors.primaryGreen,
                                        width: 2,
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 16.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            SizedBox(height: 24.h),
            // ChoiceChips cho các công dụng (hiển thị dưới card)
            _buildUsageChips(herb),
            SizedBox(height: 24.h),
            // Danh sách bài thuốc liên quan
            if (_isLoadingRelated)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_relatedRecipes.isNotEmpty) ...[
              ScanRelatedRecipesList(
                relatedRecipes: _relatedRecipes,
              ),
              SizedBox(height: 40.h),
            ] else
              SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  /// 🏷️ Hàm Build Chips mới: Đơn giản và Chính xác hơn
  Widget _buildUsageChips(HerbArticle herb) {
    // Lấy trực tiếp từ Model (Firebase Data)
    final List<String> usageTags = herb.remedyTags ?? []; 
    
    if (usageTags.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Map emoji cho sinh động (giữ nguyên logic cũ của bạn)
    String getEmojiForBenefit(String benefit) {
      final lower = benefit.toLowerCase();
      if (lower.contains('xương') || lower.contains('khớp')) return '🦴';
      if (lower.contains('mồ hôi') || lower.contains('tay')) return '🖐️';
      if (lower.contains('răng') || lower.contains('miệng')) return '🦷';
      if (lower.contains('cảm') || lower.contains('ho') || lower.contains('sốt')) return '🤧';
      if (lower.contains('tim') || lower.contains('mạch')) return '❤️';
      if (lower.contains('tiêu hóa') || lower.contains('bụng')) return '🍃';
      if (lower.contains('da') || lower.contains('mụn') || lower.contains('thương')) return '💆';
      return '💊';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn công dụng bạn muốn tìm hiểu:',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: usageTags.map((benefit) {
            final isSelected = _selectedBenefit == benefit;
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    getEmojiForBenefit(benefit),
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      benefit,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _onBenefitSelected(benefit);
                } else {
                  setState(() {
                    _selectedBenefit = null;
                  });
                }
              },
              selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
              backgroundColor: Colors.grey.shade100,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            );
          }).toList(),
        ),
      ],
    );
  }

}

