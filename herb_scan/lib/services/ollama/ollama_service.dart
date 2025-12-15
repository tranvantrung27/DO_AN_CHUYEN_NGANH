import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import '../../config/ollama_config.dart';

/// Kết quả từ Ollama API
class OllamaResponse {
  final bool success;
  final String? response;
  final String? error;

  OllamaResponse({
    required this.success,
    this.response,
    this.error,
  });
}

/// Service để kết nối với Ollama server và chat với AI model
class OllamaService {
  static final OllamaService _instance = OllamaService._internal();
  factory OllamaService() => _instance;
  OllamaService._internal();

  /// Gửi message đến Ollama và nhận phản hồi
  /// 
  /// [prompt] - Câu hỏi/câu lệnh từ người dùng
  /// 
  /// Trả về [OllamaResponse] chứa kết quả hoặc lỗi
  Future<OllamaResponse> sendMessage(String prompt) async {
    try {
      debugPrint('🤖 [Ollama] Gửi message: $prompt');

      final response = await http
          .post(
            Uri.parse(OllamaConfig.generateEndpoint),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': OllamaConfig.modelName,
              'prompt': prompt,
              'stream': OllamaConfig.stream,
              'options': {
                'temperature': OllamaConfig.temperature,
              },
            }),
          )
          .timeout(
            Duration(seconds: OllamaConfig.requestTimeout),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final botReply = data['response'] ?? 'Lỗi: Không có phản hồi từ AI';

        debugPrint('✅ [Ollama] Nhận phản hồi thành công');
        return OllamaResponse(
          success: true,
          response: botReply,
        );
      } else {
        // Parse error message từ Ollama
        String errorMsg = _parseOllamaError(response.statusCode, response.body);
        debugPrint('❌ [Ollama] Lỗi ${response.statusCode}: ${response.body}');
        return OllamaResponse(
          success: false,
          error: errorMsg,
        );
      }
    } catch (e) {
      debugPrint('❌ [Ollama] Lỗi kết nối: $e');
      
      String errorMessage;
      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('timeout')) {
        errorMessage =
            'Kết nối timeout. Vui lòng kiểm tra:\n'
            '1. Ollama server đang chạy (ollama serve)\n'
            '2. Địa chỉ IP đúng trong config\n'
            '3. Máy tính và điện thoại cùng mạng WiFi';
      } else if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        errorMessage =
            'Không thể kết nối đến Ollama server.\n'
            'Vui lòng kiểm tra:\n'
            '1. Đã chạy lệnh: set OLLAMA_HOST=0.0.0.0\n'
            '2. Đã chạy lệnh: ollama serve\n'
            '3. Địa chỉ IP trong config đúng\n'
            '4. Điện thoại và máy tính cùng mạng WiFi';
      } else {
        errorMessage = 'Lỗi: $e';
      }

      return OllamaResponse(
        success: false,
        error: errorMessage,
      );
    }
  }

  /// Kiểm tra kết nối với Ollama server
  Future<bool> checkConnection() async {
    try {
      // Thử ping một request đơn giản
      final response = await http
          .get(Uri.parse('${OllamaConfig.baseUrl}/api/tags'))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ [Ollama] Không kết nối được: $e');
      return false;
    }
  }

  /// Parse error message từ Ollama để hiển thị thân thiện hơn
  String _parseOllamaError(int statusCode, String body) {
    try {
      final errorJson = jsonDecode(body);
      final errorText = errorJson['error'] ?? errorJson['message'] ?? body;

      // Kiểm tra lỗi thiếu RAM
      if (errorText.toString().contains('memory') || 
          errorText.toString().contains('Memory') ||
          errorText.toString().contains('GiB')) {
        return _formatMemoryError(errorText.toString());
      }

      // Kiểm tra lỗi model không tìm thấy
      if (errorText.toString().contains('model') && 
          (errorText.toString().contains('not found') || 
           errorText.toString().contains('does not exist'))) {
        return '⚠️ Model "${OllamaConfig.modelName}" không tìm thấy.\n\n'
            'Vui lòng kiểm tra:\n'
            '1. Model đã được load vào Ollama chưa\n'
            '2. Tên model trong config đúng: ${OllamaConfig.modelName}\n'
            '3. Chạy: ollama list (để xem danh sách model)';
      }

      // Trả về lỗi gốc nếu không match
      return 'Lỗi Server (${statusCode}):\n$errorText';
    } catch (e) {
      // Nếu không parse được JSON, trả về body gốc
      return 'Lỗi Server (${statusCode}):\n$body';
    }
  }

  /// Format lỗi memory để dễ hiểu hơn
  String _formatMemoryError(String errorText) {
    // Extract số lượng RAM từ error message
    // Ví dụ: "model requires more system memory (4.1 GiB) than is available (3.7 GiB)"
    final requiredMatch = RegExp(r'requires.*?\((\d+\.?\d*)\s*GiB\)').firstMatch(errorText);
    final availableMatch = RegExp(r'available\s*\((\d+\.?\d*)\s*GiB\)').firstMatch(errorText);

    String requiredStr = requiredMatch?.group(1) ?? '?';
    String availableStr = availableMatch?.group(1) ?? '?';

    return '⚠️ Thiếu RAM để chạy model!\n\n'
        'Model cần: ${requiredStr} GiB\n'
        'RAM khả dụng: ${availableStr} GiB\n\n'
        '💡 Giải pháp:\n'
        '1. Đóng các ứng dụng khác đang chạy\n'
        '2. Dùng model nhỏ hơn (quantized)\n'
        '3. Giảm context length trong Ollama\n'
        '4. Nâng cấp RAM máy tính\n\n'
        'Hoặc thử model nhỏ hơn như: q4_0, q5_0';
  }
}

