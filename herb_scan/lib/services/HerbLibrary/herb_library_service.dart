import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/HerbLibrary/herb_article.dart';

/// Service để quản lý dữ liệu bài thuốc từ Firestore
class HerbLibraryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'herballibrary';

  /// Lấy tất cả bài thuốc (chỉ lấy những bài đang active)
  /// Sắp xếp theo createdAt giảm dần (mới nhất trước)
  static Stream<List<HerbArticle>> getHerbsStream({String? category}) {
    Query query = _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true);
    
    // Filter by category if provided
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    
    return query.snapshots().map((snapshot) {
      print('📦 Fetched ${snapshot.docs.length} herbs from Firestore');
      
      final herbs = <HerbArticle>[];
      for (var doc in snapshot.docs) {
        try {
          final herb = HerbArticle.fromFirestore(doc);
          herbs.add(herb);
          print('✅ Parsed herb: ${herb.name} (ID: ${doc.id})');
        } catch (e) {
          print('❌ Error parsing herb ${doc.id}: $e');
          print('   Data: ${doc.data()}');
        }
      }
      
      // Sắp xếp theo createdAt giảm dần (mới nhất trước)
      herbs.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(0);
        final bTime = b.createdAt ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
      
      print('📊 Returning ${herbs.length} herbs');
      return herbs;
    });
  }

  /// Lấy danh sách bài thuốc một lần (không stream)
  static Future<List<HerbArticle>> getHerbs({String? category}) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true);
      
      // Filter by category if provided
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }
      
      final snapshot = await query.get();

      final herbs = snapshot.docs
          .map((doc) => HerbArticle.fromFirestore(doc))
          .toList();
      
      // Sắp xếp theo createdAt giảm dần (mới nhất trước)
      herbs.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(0);
        final bTime = b.createdAt ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
      
      return herbs;
    } catch (e) {
      print('❌ Error fetching herbs: $e');
      return [];
    }
  }

  /// Lấy một bài thuốc theo ID
  static Future<HerbArticle?> getHerbById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        return HerbArticle.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching herb: $e');
      return null;
    }
  }

  /// Lấy các bài thuốc liên quan theo danh sách ID
  static Future<List<HerbArticle>> getRelatedHerbs(List<String> ids) async {
    if (ids.isEmpty) return [];
    
    try {
      // Firestore 'in' query limit is 10, so we need to batch if more than 10
      final List<HerbArticle> herbs = [];
      
      for (int i = 0; i < ids.length; i += 10) {
        final batch = ids.skip(i).take(10).toList();
        final snapshot = await _firestore
            .collection(_collectionName)
            .where(FieldPath.documentId, whereIn: batch)
            .where('isActive', isEqualTo: true)
            .get();
        
        herbs.addAll(
          snapshot.docs.map((doc) => HerbArticle.fromFirestore(doc))
        );
      }
      
      return herbs;
    } catch (e) {
      print('❌ Error fetching related herbs: $e');
      return [];
    }
  }
}

