import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../constants/app_colors.dart';
import '../../models/HerbLibrary/herb_article.dart';
import '../../services/gemini/gemini_service.dart';
import 'dart:async';

/// Model đại diện cho một message trong chat
class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

/// Màn hình Chat AI với Lương Y AI
class ChatAiScreen extends StatefulWidget {
  /// Prompt ban đầu (tùy chọn)
  /// Nếu có, sẽ tự động gửi prompt này khi mở màn hình
  final String? initialPrompt;
  
  /// Thông tin cây thuốc (tùy chọn)
  /// Nếu có, sẽ hiển thị header với hình ảnh và tên cây
  final HerbArticle? herb;
  
  /// Đường dẫn ảnh người dùng đã chụp (tùy chọn)
  /// Nếu có, sẽ dùng ảnh này thay vì herb.imageUrl
  final String? imagePath;

  const ChatAiScreen({
    super.key,
    this.initialPrompt,
    this.herb,
    this.imagePath,
  });

  @override
  State<ChatAiScreen> createState() => _ChatAiScreenState();
}

class _ChatAiScreenState extends State<ChatAiScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _hasText = false;
  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    
    // Listener để update send button state
    _messageController.addListener(() {
      final hasText = _messageController.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
    
    // Nếu có herb và initialPrompt, không thêm lời chào mặc định
    // Câu hỏi sẽ được hiển thị trong header card
    if (widget.herb == null || widget.initialPrompt == null) {
      // Thêm lời chào mặc định nếu không có herb
      _messages.add(ChatMessage(
        content: 'Xin chào! Tôi là Lương Y AI 🌿\n\n'
            'Tôi có thể tư vấn về:\n'
            '• Cây thuốc và công dụng\n'
            '• Cách sử dụng thảo dược\n'
            '• Bài thuốc dân gian\n'
            '• Lưu ý khi sử dụng\n\n'
            'Bạn muốn hỏi gì về cây thuốc?',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }

    // Nếu có initialPrompt, tự động gửi sau khi UI đã render
    if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Nếu có herb, câu hỏi đã hiển thị trong header nên chỉ gửi message
        // Nếu không có herb, thêm câu hỏi vào danh sách messages
        if (widget.herb == null) {
          setState(() {
            _messages.add(ChatMessage(
              content: widget.initialPrompt!,
              isUser: true,
              timestamp: DateTime.now(),
            ));
          });
          // Không tự động scroll - để user tự scroll
        }
        
        // Gửi message sau một chút để UI render xong
        Future.delayed(const Duration(milliseconds: 500), () {
          _sendMessageDirectly(widget.initialPrompt!);
        });
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Gửi message trực tiếp (dùng khi đã có message trong danh sách)
  Future<void> _sendMessageDirectly(String text) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _geminiService.sendMessage(text);

      setState(() {
        _isLoading = false;
        if (response.success && response.response != null) {
          _messages.add(ChatMessage(
            content: response.response!,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        } else {
          _messages.add(ChatMessage(
            content: '❌ ${response.error ?? "Không thể kết nối đến AI. Vui lòng kiểm tra lại cấu hình."}',
            isUser: false,
            timestamp: DateTime.now(),
          ));
        }
      });

      // Không tự động scroll - để user tự scroll
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add(ChatMessage(
          content: '❌ Đã xảy ra lỗi: $e',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      // Không tự động scroll - để user tự scroll
    }
  }

  /// Gửi message đến AI
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Thêm message của user vào danh sách
    setState(() {
      _messages.add(ChatMessage(
        content: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    // Đóng keyboard khi gửi tin nhắn
    FocusScope.of(context).unfocus();
    // Không tự động scroll - để user tự scroll

    try {
      // Gửi request đến Gemini
      final response = await _geminiService.sendMessage(text);

      setState(() {
        _isLoading = false;
        if (response.success && response.response != null) {
          _messages.add(ChatMessage(
            content: response.response!,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        } else {
          // Hiển thị lỗi
          _messages.add(ChatMessage(
            content: '❌ ${response.error ?? "Không thể kết nối đến AI. Vui lòng kiểm tra lại cấu hình."}',
            isUser: false,
            timestamp: DateTime.now(),
          ));
        }
      });

      // Không tự động scroll - để user tự scroll
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add(ChatMessage(
          content: '❌ Đã xảy ra lỗi: $e',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      // Không tự động scroll - để user tự scroll
    }
  }

  /// Parse scientific name từ description
  String? _parseScientificName(String description) {
    final match = RegExp(r'\(([^)]+)\)').firstMatch(description);
    return match?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    final hasHerb = widget.herb != null;
    final herb = widget.herb;
    final scientificName = herb?.scientificName ?? 
        (herb != null ? _parseScientificName(herb.description) : null);

    if (hasHerb) {
      // Màn hình chat với header đẹp (có thông tin cây thuốc)
      return Scaffold(
        backgroundColor: AppColors.backgroundCream,
        body: GestureDetector(
          onTap: () {
            // Đóng keyboard khi tap vào vùng trống
            FocusScope.of(context).unfocus();
          },
          behavior: HitTestBehavior.translucent, // Không chặn scroll của ListView
          child: Column(
            children: [
            // Header cố định với hình ảnh
            _buildHerbHeader(herb!, scientificName),
            // Câu hỏi đã chọn
            if (widget.initialPrompt != null)
              Container(
                margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.question_mark_rounded,
                      color: AppColors.primaryGreen,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        widget.initialPrompt!,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Chat messages - hiển thị từ đầu, không auto scroll
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Tính chiều cao input area: 12h padding top + 48h button + 12h padding bottom + SafeArea
                  final inputAreaHeight = 12.h + 48.h + 12.h + MediaQuery.of(context).padding.bottom;
                  
                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                      left: 16.w,
                      top: 16.h,
                      right: 16.w,
                      bottom: inputAreaHeight + 8.h, // Padding = chiều cao input + khoảng cách nhỏ
                    ),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return _buildLoadingIndicator();
                      }
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  );
                },
              ),
            ),
            // Input area - đặt ở dưới cùng
            _buildInputArea(),
          ],
          ),
        ),
      );
    } else {
      // Màn hình chat thông thường (không có thông tin cây thuốc)
      return Scaffold(
        backgroundColor: AppColors.backgroundCream,
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.w),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ),
              SizedBox(width: 12.w),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lương Y AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    'Đang hoạt động',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: GestureDetector(
          onTap: () {
            // Đóng keyboard khi tap vào vùng trống
            FocusScope.of(context).unfocus();
          },
          behavior: HitTestBehavior.translucent, // Không chặn scroll của ListView
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Tính chiều cao input area: 12h padding top + 48h button + 12h padding bottom + SafeArea
                    final inputAreaHeight = 12.h + 48.h + 12.h + MediaQuery.of(context).padding.bottom;
                    
                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(
                        left: 16.w,
                        top: 16.h,
                        right: 16.w,
                        bottom: inputAreaHeight + 8.h, // Padding = chiều cao input + khoảng cách nhỏ
                      ),
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return _buildLoadingIndicator();
                        }
                        final message = _messages[index];
                        return _buildMessageBubble(message);
                      },
                    );
                  },
                ),
              ),
              _buildInputArea(),
            ],
          ),
        ),
      );
    }
  }

  /// Widget hiển thị header với hình ảnh cây thuốc
  Widget _buildHerbHeader(HerbArticle herb, String? scientificName) {
    return Container(
      height: 250.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image - ưu tiên ảnh người dùng chụp
          widget.imagePath != null && widget.imagePath!.isNotEmpty
              ? Image.file(
                  File(widget.imagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, size: 48),
                  ),
                )
              : herb.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: herb.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported, size: 48),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported, size: 48),
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
          // Back button - sửa lại vị trí về góc trái trên
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Material(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20.r),
                    child: Padding(
                      padding: EdgeInsets.all(8.w),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Tên cây và tên khoa học
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
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                if (scientificName != null) ...[
                  SizedBox(height: 6.h),
                  Text(
                    scientificName,
                    style: TextStyle(
                      color: Colors.green.shade200,
                      fontSize: 16.sp,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget hiển thị message bubble
  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isUser ? 16.r : 4.r),
            bottomRight: Radius.circular(isUser ? 4.r : 16.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : AppColors.textPrimary,
                fontSize: 14.sp,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: isUser
                    ? Colors.white.withOpacity(0.7)
                    : AppColors.textLight,
                fontSize: 10.sp,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget hiển thị loading indicator
  Widget _buildLoadingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16.w,
              height: 16.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGreen,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Đang suy nghĩ...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.sp,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget input area - không có background trắng, chỉ input và button
  Widget _buildInputArea() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: 120.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGreyLight,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: AppColors.borderLight.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Nhập câu hỏi về cây thuốc...',
                    hintStyle: TextStyle(
                      color: AppColors.textPlaceholder,
                      fontSize: 15.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 14.h,
                    ),
                    isDense: true,
                  ),
                  maxLines: null,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontFamily: 'Poppins',
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                  onSubmitted: (_) {
                    if (!_isLoading) {
                      _sendMessage();
                    }
                  },
                ),
              ),
            ),
            SizedBox(width: 10.w),
            // Send button - đẹp hơn
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: (_isLoading || !_hasText) ? null : _sendMessage,
                borderRadius: BorderRadius.circular(24.r),
                child: Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    gradient: (_isLoading || !_hasText)
                        ? LinearGradient(
                            colors: [
                              AppColors.primaryGreen.withValues(alpha: 0.4),
                              AppColors.secondaryGreen.withValues(alpha: 0.4),
                            ],
                          )
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryGreen,
                              AppColors.secondaryGreen,
                            ],
                          ),
                    boxShadow: (_isLoading || !_hasText)
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: _isLoading
                      ? Center(
                          child: SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format thời gian
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
