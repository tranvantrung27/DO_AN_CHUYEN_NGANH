/// Model cho nội dung của màn hình intro
/// Chứa thông tin về hình ảnh, tiêu đề và mô tả của từng slide intro
class IntroContent {
  /// Đường dẫn đến hình ảnh
  final String imagePath;
  
  /// Tiêu đề của slide
  final String title;
  
  /// Mô tả chi tiết của slide
  final String description;

  /// Constructor
  const IntroContent({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  /// Copy constructor để tạo instance mới với một số thuộc tính thay đổi
  IntroContent copyWith({
    String? imagePath,
    String? title,
    String? description,
  }) {
    return IntroContent(
      imagePath: imagePath ?? this.imagePath,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  /// Chuyển đổi sang Map để lưu trữ hoặc serialize
  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'title': title,
      'description': description,
    };
  }

  /// Tạo instance từ Map
  factory IntroContent.fromMap(Map<String, dynamic> map) {
    return IntroContent(
      imagePath: map['imagePath'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
    );
  }

  /// Override toString để debug dễ dàng
  @override
  String toString() {
    return 'IntroContent(imagePath: $imagePath, title: $title, description: $description)';
  }

  /// Override equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is IntroContent &&
        other.imagePath == imagePath &&
        other.title == title &&
        other.description == description;
  }

  /// Override hashCode
  @override
  int get hashCode {
    return imagePath.hashCode ^ title.hashCode ^ description.hashCode;
  }
}

/// Extension methods cho IntroContent
extension IntroContentExtension on IntroContent {
  /// Kiểm tra xem content có hợp lệ không
  bool get isValid {
    return imagePath.isNotEmpty && 
           title.isNotEmpty && 
           description.isNotEmpty;
  }

  /// Lấy tên file từ đường dẫn hình ảnh
  String get imageFileName {
    return imagePath.split('/').last;
  }
}
