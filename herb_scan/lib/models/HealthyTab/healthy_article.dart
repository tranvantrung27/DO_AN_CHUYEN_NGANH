import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_utils.dart';
import '../../utils/date_format_vn.dart';

/// Model cho bài viết về sống khỏe từ Firebase
class HealthyArticle {
  final String id;
  final String imageUrl; // Link ảnh trên mạng
  final String title; // Tiêu đề lớn
  final String subtitle; // Tiêu đề nhỏ
  final String content; // Nội dung bài viết
  final DateTime? createdAt;
  final bool isActive;

  HealthyArticle({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.content = '',
    this.createdAt,
    this.isActive = true,
  });

  /// Tự động tính dateText từ createdAt
  String get dateText {
    if (createdAt == null) return '';
    return formatVietnameseDate(createdAt!.toLocal());
  }

  /// Tự động tính timeAgo từ createdAt
  String get timeAgo {
    if (createdAt == null) return '';
    return AppUtils.formatRelativeTime(createdAt!.toLocal());
  }

  /// Tạo từ Firestore document
  /// Tự động tạo createdAt nếu chưa có (dùng thời gian hiện tại)
  factory HealthyArticle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime? createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    
    // Nếu chưa có createdAt, tự động tạo từ thời gian hiện tại
    createdAt ??= DateTime.now();
    
    return HealthyArticle(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      content: data['content'] ?? '',
      createdAt: createdAt,
      isActive: data['isActive'] ?? true,
    );
  }

  /// Chuyển đổi sang Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'isActive': isActive,
    };
  }
}

