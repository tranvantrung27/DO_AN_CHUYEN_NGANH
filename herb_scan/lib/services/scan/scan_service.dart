import 'dart:io';
import 'package:herb_scan/models/scan/scan_result.dart';
import 'package:herb_scan/data/mock_herb_data.dart';

/// Service xử lý scan và nhận diện lá cây
/// Hiện tại sử dụng mock data, sau này sẽ thay thế bằng mô hình AI thật
class ScanService {
  static final ScanService _instance = ScanService._internal();
  factory ScanService() => _instance;
  ScanService._internal();

  /// Scan ảnh và nhận diện lá cây
  /// 
  /// [imagePath]: Đường dẫn đến file ảnh cần scan
  /// 
  /// Trả về [ScanResult] chứa kết quả nhận diện
  Future<ScanResult> scanImage(String imagePath) async {
    try {
      // Kiểm tra file tồn tại
      final file = File(imagePath);
      if (!await file.exists()) {
        return ScanResult.failure(
          imagePath: imagePath,
          errorMessage: 'Không tìm thấy file ảnh',
        );
      }

      // TODO: Khi có mô hình AI, thay thế phần này bằng:
      // 1. Load mô hình (TensorFlow Lite, ONNX, etc.)
      // 2. Preprocess ảnh (resize, normalize, etc.)
      // 3. Chạy inference
      // 4. Post-process kết quả
      
      // Tạm thời: Mock - giả lập thời gian xử lý
      await Future.delayed(const Duration(seconds: 2));

      // Sử dụng mock data cụ thể cho 2 loại lá
      final mockHerbs = MockHerbData.mockHerbs;
      
      if (mockHerbs.isEmpty) {
        return ScanResult.failure(
          imagePath: imagePath,
          errorMessage: 'Không tìm thấy dữ liệu cây thuốc',
        );
      }

      // Mock: Chọn ngẫu nhiên giữa 2 loại lá (Lá Trầu Không hoặc Lá Tía Tô)
      final random = DateTime.now().millisecondsSinceEpoch;
      final selectedIndex = random % mockHerbs.length;
      final identifiedHerb = mockHerbs[selectedIndex];

      // Mock: Tạo độ tin cậy ngẫu nhiên (80% - 95%)
      final confidence = 0.80 + (random % 15) / 100.0;

      // Mock: Tạo danh sách top predictions từ mock data
      final predictions = <HerbPrediction>[];
      for (int i = 0; i < mockHerbs.length && i < 5; i++) {
        final index = (selectedIndex + i) % mockHerbs.length;
        // Bỏ qua nếu là herb đã được chọn
        if (index == selectedIndex && i > 0) continue;
        
        final predConfidence = confidence - (i * 0.15);
        if (predConfidence > 0.1) {
          predictions.add(
            HerbPrediction(
              herb: mockHerbs[index],
              confidence: predConfidence.clamp(0.0, 1.0),
            ),
          );
        }
      }

      // Sắp xếp theo độ tin cậy giảm dần
      predictions.sort((a, b) => b.confidence.compareTo(a.confidence));

      return ScanResult.success(
        imagePath: imagePath,
        identifiedHerb: identifiedHerb,
        confidence: confidence,
        predictions: predictions.take(5).toList(),
      );
    } catch (e) {
      return ScanResult.failure(
        imagePath: imagePath,
        errorMessage: 'Lỗi khi xử lý ảnh: ${e.toString()}',
      );
    }
  }

  /// Lưu kết quả scan vào lịch sử
  /// TODO: Implement lưu vào Firestore hoặc local database
  Future<bool> saveScanResult(ScanResult result) async {
    try {
      // TODO: Lưu vào Firestore collection 'scan_history'
      // hoặc local database (SQLite)
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      print('❌ Error saving scan result: $e');
      return false;
    }
  }

  /// Xử lý ảnh trước khi đưa vào mô hình
  /// TODO: Implement preprocessing (resize, normalize, etc.)
  Future<String?> preprocessImage(String imagePath) async {
    try {
      // TODO: 
      // 1. Resize ảnh về kích thước mô hình yêu cầu (ví dụ: 224x224)
      // 2. Normalize pixel values
      // 3. Convert sang format mô hình cần (RGB, BGR, etc.)
      // 4. Lưu ảnh đã xử lý tạm thời
      
      return imagePath; // Tạm thời trả về đường dẫn gốc
    } catch (e) {
      print('❌ Error preprocessing image: $e');
      return null;
    }
  }
}

