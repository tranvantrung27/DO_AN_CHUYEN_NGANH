import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/DiseasesTab/disease_article.dart';

/// Service để quản lý dữ liệu bài viết về bệnh từ Firestore
class DiseaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'diseases';

  /// Lấy tất cả bài viết về bệnh (chỉ lấy những bài đang active)
  /// Sắp xếp theo createdAt giảm dần (mới nhất trước)
  /// Tự động tạo createdAt trong memory nếu chưa có (không lưu vào Firestore)
  static Stream<List<DiseaseArticle>> getDiseasesStream() {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final articles = snapshot.docs
              .map((doc) => DiseaseArticle.fromFirestore(doc))
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
  static Future<List<DiseaseArticle>> getDiseases() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();

      final articles = snapshot.docs
          .map((doc) => DiseaseArticle.fromFirestore(doc))
          .toList();
      
      // Sắp xếp theo createdAt giảm dần (mới nhất trước)
      articles.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(0);
        final bTime = b.createdAt ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
      
      return articles;
    } catch (e) {
      print('❌ Error fetching diseases: $e');
      return [];
    }
  }

  /// Thêm bài viết mới
  static Future<String?> addDisease(DiseaseArticle article) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(article.toFirestore());
      print('✅ Disease article added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error adding disease: $e');
      return null;
    }
  }

  /// Cập nhật bài viết
  static Future<bool> updateDisease(String id, DiseaseArticle article) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(id)
          .update(article.toFirestore());
      print('✅ Disease article updated: $id');
      return true;
    } catch (e) {
      print('❌ Error updating disease: $e');
      return false;
    }
  }

  /// Xóa bài viết (soft delete bằng cách set isActive = false)
  static Future<bool> deleteDisease(String id) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(id)
          .update({'isActive': false});
      print('✅ Disease article deleted: $id');
      return true;
    } catch (e) {
      print('❌ Error deleting disease: $e');
      return false;
    }
  }
}

