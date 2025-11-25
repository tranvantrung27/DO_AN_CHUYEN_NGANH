import 'package:cloud_firestore/cloud_firestore.dart';

/// Model cho bài thuốc từ Firebase
class HerbArticle {
  final String id;
  final String imageUrl;
  final String name; // Tên bài thuốc
  final String description; // Mô tả
  final String? category; // Triệu chứng thường gặp
  final String? date; // Ngày đăng (format: "Jun 10, 2021")
  final List<String>? relatedArticles; // ID các bài viết liên quan
  final List<String>? tags; // Thẻ bài viết
  final DateTime? createdAt;
  final bool isActive;

  HerbArticle({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.description,
    this.category,
    this.date,
    this.relatedArticles,
    this.tags,
    this.createdAt,
    this.isActive = true,
  });

  /// Tạo từ Firestore document
  factory HerbArticle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime? createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    
    // Parse relatedArticles
    List<String>? relatedArticles;
    if (data['relatedArticles'] != null) {
      if (data['relatedArticles'] is List) {
        relatedArticles = (data['relatedArticles'] as List)
            .map((e) => e.toString())
            .toList();
      } else if (data['relatedArticles'] is String) {
        relatedArticles = (data['relatedArticles'] as String)
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }
    
    // Parse tags
    List<String>? tags;
    if (data['tags'] != null) {
      if (data['tags'] is List) {
        tags = (data['tags'] as List)
            .map((e) => e.toString())
            .toList();
      } else if (data['tags'] is String) {
        tags = (data['tags'] as String)
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }
    
    return HerbArticle(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] as String?,
      date: data['date'] as String?,
      relatedArticles: relatedArticles,
      tags: tags,
      createdAt: createdAt,
      isActive: data['isActive'] ?? true,
    );
  }

  /// Chuyển đổi sang Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl,
      'name': name,
      'description': description,
      if (category != null) 'category': category,
      if (date != null) 'date': date,
      if (relatedArticles != null && relatedArticles!.isNotEmpty) 
        'relatedArticles': relatedArticles,
      if (tags != null && tags!.isNotEmpty) 'tags': tags,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
      'isActive': isActive,
    };
  }
}

