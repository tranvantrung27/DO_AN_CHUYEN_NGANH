import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/herb_categories.dart';
import '../../widgets/herballibrary/herb_category_navigation.dart';

/// Service để quản lý danh mục thảo dược từ Firestore
class HerbCategoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'herb_categories';

  /// Lấy tất cả danh mục từ Firestore
  /// Nếu Firestore trống, trả về danh sách mặc định
  static Stream<List<HerbCategory>> getCategoriesStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        // Trả về danh sách mặc định nếu Firestore trống
        return HerbCategories.defaultCategories;
      }
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return HerbCategory(
          id: doc.id,
          name: data['name'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
        );
      }).toList();
    });
  }

  /// Lấy danh sách danh mục một lần (không stream)
  static Future<List<HerbCategory>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('name')
          .get();
      
      if (snapshot.docs.isEmpty) {
        // Trả về danh sách mặc định nếu Firestore trống
        return HerbCategories.defaultCategories;
      }
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return HerbCategory(
          id: doc.id,
          name: data['name'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('❌ Error fetching categories: $e');
      // Trả về danh sách mặc định nếu có lỗi
      return HerbCategories.defaultCategories;
    }
  }
}

