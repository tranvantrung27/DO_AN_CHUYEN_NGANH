/// Cấu hình kết nối với Google Gemini API
/// 
/// ⚠️ LƯU Ý BẢO MẬT:
/// - API Key được lưu trong code này có thể bị lộ khi build app
/// - Để bảo mật tốt hơn, nên dùng backend server làm proxy
/// - Hoặc dùng environment variables (cần setup phức tạp hơn)
/// - Hiện tại để đơn giản, API key được lưu trực tiếp ở đây
class GeminiConfig {
  /// API Key của Google Gemini
  /// 
  /// ⚠️ CẢNH BÁO: API Key này có thể bị lộ khi build app.
  /// Nên rotate key thường xuyên và giới hạn quota trong Google Cloud Console.
  static const String apiKey = 'AIzaSyC6o0JOLFrRWjRoAM6L1y2pV6lwdMUBhmc';
  
  /// Model name
  /// - 'gemini-2.0-flash': Model Flash mới nhất, nhanh và ổn định (khuyến nghị)
  /// - 'gemini-pro': Model Pro ổn định (fallback nếu gemini-2.0-flash lỗi)
  static const String modelName = 'gemini-2.0-flash'; // Model Flash mới nhất - nhanh và ổn định
  
  /// Temperature cho model (0.0 - 1.0)
  /// Giá trị thấp hơn = trả lời chính xác hơn, ít sáng tạo
  /// Giá trị cao hơn = trả lời sáng tạo hơn, có thể không chính xác
  static const double temperature = 0.7;
  
  /// Timeout cho request (giây)
  static const int requestTimeout = 30;
  
  /// Max output tokens (giới hạn độ dài câu trả lời)
  static const int maxOutputTokens = 2048;
}

