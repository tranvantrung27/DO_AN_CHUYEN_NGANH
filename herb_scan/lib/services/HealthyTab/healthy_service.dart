import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/HealthyTab/healthy_article.dart';

/// Service để quản lý dữ liệu bài viết về sống khỏe từ Firestore
class HealthyService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'healthy';

  /// Lấy tất cả bài viết về sống khỏe (chỉ lấy những bài đang active)
  /// Sắp xếp theo createdAt giảm dần (mới nhất trước)
  /// Tự động tạo createdAt trong memory nếu chưa có (không lưu vào Firestore)
  static Stream<List<HealthyArticle>> getHealthyStream() {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final articles = snapshot.docs
              .map((doc) => HealthyArticle.fromFirestore(doc))
              .toList();
          
          // Sắp xếp theo createdAt giảm dần (mới nhất trước)
          articles.sort((a, b) {
            final aTime = a.createdAt ?? DateTime(0);
            final bTime = b.createdAt ?? DateTime(0);
            return bTime.compareTo(aTime);
          });
          
          return articles;
        });
  }

  /// Lấy danh sách bài viết một lần (không stream)
  /// Tự động tạo createdAt trong memory nếu chưa có (không lưu vào Firestore)
  static Future<List<HealthyArticle>> getHealthy() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();

      final articles = snapshot.docs
          .map((doc) => HealthyArticle.fromFirestore(doc))
          .toList();
      
      // Sắp xếp theo createdAt giảm dần (mới nhất trước)
      articles.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(0);
        final bTime = b.createdAt ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
      
      return articles;
    } catch (e) {
      return [];
    }
  }

  /// Thêm bài viết mới
  static Future<String?> addHealthy(HealthyArticle article) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(article.toFirestore());
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  /// Cập nhật bài viết
  static Future<bool> updateHealthy(String id, HealthyArticle article) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(id)
          .update(article.toFirestore());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Xóa bài viết (soft delete bằng cách set isActive = false)
  static Future<bool> deleteHealthy(String id) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(id)
          .update({'isActive': false});
      return true;
    } catch (e) {
      return false;
    }
  }
}

