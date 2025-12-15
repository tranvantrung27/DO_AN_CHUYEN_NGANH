import 'package:herb_scan/models/HerbLibrary/herb_article.dart';

/// Model cho kết quả scan lá cây
class ScanResult {
  final String? imagePath; // Đường dẫn ảnh đã scan
  final HerbArticle? identifiedHerb; // Cây thuốc được nhận diện
  final double? confidence; // Độ tin cậy (0.0 - 1.0)
  final List<HerbPrediction>? predictions; // Danh sách các dự đoán (top 3-5)
  final DateTime scannedAt; // Thời gian scan
  final bool isSuccess; // Trạng thái thành công
  final String? errorMessage; // Thông báo lỗi nếu có

  ScanResult({
    this.imagePath,
    this.identifiedHerb,
    this.confidence,
    this.predictions,
    DateTime? scannedAt,
    this.isSuccess = false,
    this.errorMessage,
  }) : scannedAt = scannedAt ?? DateTime.now();

  /// Tạo kết quả thành công
  factory ScanResult.success({
    required String imagePath,
    required HerbArticle identifiedHerb,
    required double confidence,
    List<HerbPrediction>? predictions,
  }) {
    return ScanResult(
      imagePath: imagePath,
      identifiedHerb: identifiedHerb,
      confidence: confidence,
      predictions: predictions,
      isSuccess: true,
    );
  }

  /// Tạo kết quả thất bại
  factory ScanResult.failure({
    String? imagePath,
    required String errorMessage,
  }) {
    return ScanResult(
      imagePath: imagePath,
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }

  /// Kiểm tra có nhận diện được không
  bool get hasIdentification => isSuccess && identifiedHerb != null;

  /// Lấy độ tin cậy dạng phần trăm
  String get confidencePercentage {
    if (confidence == null) return '0%';
    return '${(confidence! * 100).toStringAsFixed(1)}%';
  }
}

/// Model cho một dự đoán cây thuốc
class HerbPrediction {
  final HerbArticle herb;
  final double confidence; // Độ tin cậy (0.0 - 1.0)

  HerbPrediction({
    required this.herb,
    required this.confidence,
  });

  /// Lấy độ tin cậy dạng phần trăm
  String get confidencePercentage {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }
}

