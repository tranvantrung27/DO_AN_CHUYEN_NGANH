/// Cấu hình kết nối với Ollama server
/// 
/// HƯỚNG DẪN SỬ DỤNG:
/// 1. Nếu chạy trên Máy ảo Android (Emulator): Dùng '10.0.2.2'
/// 2. Nếu chạy trên Điện thoại thật: Dùng IP LAN của máy tính (VD: 192.168.1.X)
///    - Mở CMD trên Windows, gõ: ipconfig
///    - Tìm dòng IPv4 Address (Ví dụ: 192.168.1.5)
///    - Điện thoại và Máy tính phải bắt chung 1 mạng Wifi
/// 3. Nếu chạy trên Windows App: Dùng 'localhost' hoặc '127.0.0.1'
class OllamaConfig {
  /// Địa chỉ IP của máy tính chạy Ollama server
  /// 
  /// ⚠️ LƯU Ý: 
  /// - Nếu chạy trên Android Emulator: Dùng 'http://10.0.2.2:11434'
  /// - Nếu chạy trên điện thoại thật: Dùng IP LAN của máy tính (VD: 'http://192.168.1.124:11434')
  ///   Để tìm IP: Mở CMD, gõ ipconfig, tìm "IPv4 Address" của Wi-Fi adapter
  /// - Nếu chạy trên Windows App: Dùng 'http://localhost:11434'
  /// 
  /// IP hiện tại: 192.168.1.124 (Wi-Fi của máy tính)
  static const String baseUrl = 'http://192.168.1.124:11434';
  
  /// Tên model đã huấn luyện
  static const String modelName = 'luong_y';
  
  /// Endpoint API generate
  static String get generateEndpoint => '$baseUrl/api/generate';
  
  /// Temperature cho model (0.0 - 1.0)
  /// Giá trị thấp hơn = trả lời chính xác hơn, ít sáng tạo
  /// Giá trị cao hơn = trả lời sáng tạo hơn, có thể không chính xác
  static const double temperature = 0.3;
  
  /// Timeout cho request (giây)
  static const int requestTimeout = 30;
  
  /// Có stream response không (hiện tại dùng false để đơn giản)
  static const bool stream = false;
}

