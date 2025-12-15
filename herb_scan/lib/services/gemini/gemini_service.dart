import 'dart:async';
import 'dart:typed_data'; // Cần để xử lý ảnh
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../config/gemini_config.dart';

/// Kết quả từ Gemini API (tương tự OllamaResponse để dễ thay thế)
class GeminiResponse {
  final bool success;
  final String? response;
  final String? error;

  GeminiResponse({
    required this.success,
    this.response,
    this.error,
  });
}

/// Service để kết nối với Google Gemini API và chat với AI model
/// Sử dụng package google_generative_ai chính thức từ Google
class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  // Model instance - khởi tạo một lần
  GenerativeModel? _model;

  /// Khởi tạo model
  GenerativeModel get _getModel {
    _model ??= GenerativeModel(
      model: GeminiConfig.modelName,
      apiKey: GeminiConfig.apiKey,
      generationConfig: GenerationConfig(
        temperature: GeminiConfig.temperature,
        maxOutputTokens: GeminiConfig.maxOutputTokens,
      ),
    );
    return _model!;
  }

  /// Gửi message đến Gemini và nhận phản hồi
  /// 
  /// [prompt] - Câu hỏi/câu lệnh từ người dùng
  /// [imageBytes] - Dữ liệu ảnh (Uint8List) - Nếu có ảnh thì truyền vào
  ///                Hỗ trợ cho việc nhận diện thảo mộc từ ảnh
  /// 
  /// Trả về [GeminiResponse] chứa kết quả hoặc lỗi
  Future<GeminiResponse> sendMessage(String prompt, {Uint8List? imageBytes}) async {
    try {
      debugPrint('🤖 [Gemini] Gửi message: $prompt');
      debugPrint('📝 [Gemini] Model: ${GeminiConfig.modelName}');
      if (imageBytes != null) {
        debugPrint('🖼️ [Gemini] Có ảnh kèm theo (${imageBytes.length} bytes)');
      }

      final model = _getModel;
      final List<Content> content;

      // Xử lý content: có ảnh hoặc chỉ text
      if (imageBytes != null) {
        // Trường hợp 1: Có ảnh (Dùng cho nhận diện lá cây/thảo mộc)
        content = [
          Content.multi([
            TextPart(prompt),
            DataPart('image/jpeg', imageBytes), // Hỗ trợ JPEG/PNG
          ])
        ];
      } else {
        // Trường hợp 2: Chỉ có text (Chat thông thường)
        content = [Content.text(prompt)];
      }
      
      // Gửi request với timeout
      final response = await model
          .generateContent(content)
          .timeout(
            Duration(seconds: GeminiConfig.requestTimeout),
            onTimeout: () {
              throw TimeoutException(
                'Request timeout sau ${GeminiConfig.requestTimeout} giây',
                Duration(seconds: GeminiConfig.requestTimeout),
              );
            },
          );

      // Lấy text từ response
      final responseText = response.text;
      
      if (responseText != null && responseText.isNotEmpty) {
        debugPrint('✅ [Gemini] Nhận phản hồi thành công');
        return GeminiResponse(
          success: true,
          response: responseText,
        );
      } else {
        debugPrint('⚠️ [Gemini] Phản hồi rỗng');
        return GeminiResponse(
          success: false,
          error: 'Không nhận được phản hồi từ AI. Vui lòng thử lại.',
        );
      }
    } on TimeoutException catch (e) {
      debugPrint('❌ [Gemini] Timeout: $e');
      return GeminiResponse(
        success: false,
        error: '⏱️ Kết nối timeout.\n\n'
            'Vui lòng kiểm tra:\n'
            '1. Kết nối internet\n'
            '2. Thử lại sau vài giây',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [Gemini] Lỗi chi tiết: $e');
      debugPrint('📚 [Gemini] Stack trace: $stackTrace');
      
      String errorMessage;
      
      // Parse các lỗi phổ biến
      final errorStr = e.toString().toLowerCase();
      final errorFull = e.toString();
      
      // In ra console để debug
      debugPrint('🔍 [Gemini] Error string: $errorStr');
      
      if (errorStr.contains('api key') || errorStr.contains('authentication') || errorStr.contains('401')) {
        errorMessage = '🔑 Lỗi xác thực API Key.\n\n'
            'Vui lòng kiểm tra:\n'
            '1. API Key đúng trong config (gemini_config.dart)\n'
            '2. API Key còn hạn sử dụng\n'
            '3. API Key đã được kích hoạt "Generative Language API" trong Google Cloud Console\n'
            '4. Tạo API key mới nếu cần';
      } else if (errorStr.contains('quota') || errorStr.contains('rate limit') || errorStr.contains('429')) {
        errorMessage = '📊 Đã vượt quá quota.\n\n'
            'Vui lòng:\n'
            '1. Kiểm tra quota trong Google Cloud Console\n'
            '2. Đợi một lúc rồi thử lại\n'
            '3. Hoặc nâng cấp quota';
      } else if (errorStr.contains('network') || errorStr.contains('connection') || errorStr.contains('socket')) {
        errorMessage = '🌐 Lỗi kết nối mạng.\n\n'
            'Vui lòng kiểm tra:\n'
            '1. Kết nối internet\n'
            '2. Firewall/VPN không chặn\n'
            '3. Thử lại sau vài giây';
      } else if (errorStr.contains('not found') || errorStr.contains('is not found') || errorStr.contains('404') || errorStr.contains('v1beta')) {
        errorMessage = '⚠️ Model "${GeminiConfig.modelName}" không tìm thấy.\n\n'
            'Lỗi: $errorFull\n\n'
            'Giải pháp:\n'
            '1. Đảm bảo dùng model "gemini-pro" (không có số version)\n'
            '2. Kiểm tra package google_generative_ai đã cập nhật lên ^0.4.7\n'
            '3. Chạy: flutter clean && flutter pub get\n'
            '4. Tắt app hoàn toàn và chạy lại (không hot reload)';
      } else {
        // Hiển thị lỗi đầy đủ để debug
        errorMessage = '❌ Lỗi: $errorFull\n\n'
            'Vui lòng:\n'
            '1. Kiểm tra console log để xem chi tiết\n'
            '2. Thử lại sau vài giây\n'
            '3. Kiểm tra API key và quota trong Google Cloud Console';
      }

      return GeminiResponse(
        success: false,
        error: errorMessage,
      );
    }
  }

  /// Kiểm tra kết nối với Gemini API (test với một request nhỏ)
  Future<bool> checkConnection() async {
    try {
      final model = _getModel;
      final testResponse = await model
          .generateContent([Content.text('test')])
          .timeout(const Duration(seconds: 5));
      
      return testResponse.text != null && testResponse.text!.isNotEmpty;
    } catch (e) {
      debugPrint('❌ [Gemini] Không kết nối được: $e');
      return false;
    }
  }
}

