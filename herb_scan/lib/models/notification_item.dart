import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_utils.dart';
import 'DiseasesTab/disease_article.dart';

/// Model cho notification item (bài viết mới)
class NotificationItem {
  final String id;
  final String collection; // 'diseases' hoặc 'healthy'
  final String title;
  final String subtitle;
  final String imageUrl;
  final String content;
  final DateTime? createdAt;
  final bool isActive;
  final bool isRead; // Đã đọc chưa

  NotificationItem({
    required this.id,
    required this.collection,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.content = '',
    this.createdAt,
    this.isActive = true,
    this.isRead = false,
  });

  /// Tạo từ Map (từ NotificationBadgeService)
  factory NotificationItem.fromMap(Map<String, dynamic> map, {bool isRead = false}) {
    return NotificationItem(
      id: map['id'] ?? '',
      collection: map['collection'] ?? 'diseases',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : (map['createdAt'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] ?? true,
      isRead: isRead,
    );
  }

  /// Copy với isRead mới
  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      collection: collection,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      content: content,
      createdAt: createdAt,
      isActive: isActive,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Chuyển đổi sang DiseaseArticle để dùng trong detail screen
  DiseaseArticle toDiseaseArticle() {
    return DiseaseArticle(
      id: id,
      imageUrl: imageUrl,
      title: title,
      subtitle: subtitle,
      content: content,
      createdAt: createdAt,
      isActive: isActive,
    );
  }

  /// Tự động tính timeAgo từ createdAt
  String get timeAgo {
    if (createdAt == null) return '';
    return AppUtils.formatRelativeTime(createdAt!.toLocal());
  }
}

