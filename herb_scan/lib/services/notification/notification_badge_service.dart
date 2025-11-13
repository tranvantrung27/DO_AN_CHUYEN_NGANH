import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service để quản lý badge số bài mới trên notification icon
class NotificationBadgeService {
  static const String _lastViewedKey = 'last_notification_viewed_time';
  static const String _readArticlesKey = 'read_articles_ids';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy thời điểm user xem notification lần cuối
  static Future<DateTime?> _getLastViewedTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastViewedKey);
      if (timestamp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      print('❌ Error getting last viewed time: $e');
      return null;
    }
  }

  /// Lưu thời điểm user xem notification (hiện tại)
  static Future<void> markAsViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastViewedKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('❌ Error saving last viewed time: $e');
    }
  }

  /// Đếm số bài mới từ cả diseases và healthy collections
  /// Bài mới = bài được tạo sau thời điểm user xem notification lần cuối
  static Future<int> getNewArticlesCount() async {
    try {
      final lastViewed = await _getLastViewedTime();
      
      // Nếu chưa từng xem, không có bài mới
      if (lastViewed == null) {
        return 0;
      }

      int count = 0;

      // Đếm bài mới từ diseases collection
      try {
        final diseasesQuery = await _firestore
            .collection('diseases')
            .where('isActive', isEqualTo: true)
            .get();

        for (var doc in diseasesQuery.docs) {
          final data = doc.data();
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          if (createdAt != null && createdAt.isAfter(lastViewed)) {
            count++;
          }
        }
      } catch (e) {
        print('⚠️ Error reading diseases collection: $e');
        // Tiếp tục đếm từ healthy nếu có lỗi
      }

      // Đếm bài mới từ healthy collection
      try {
        final healthyQuery = await _firestore
            .collection('healthy')
            .where('isActive', isEqualTo: true)
            .get();

        for (var doc in healthyQuery.docs) {
          final data = doc.data();
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          if (createdAt != null && createdAt.isAfter(lastViewed)) {
            count++;
          }
        }
      } catch (e) {
        print('⚠️ Error reading healthy collection: $e');
        // Nếu lỗi permission, chỉ đếm từ diseases
      }

      return count;
    } catch (e) {
      print('❌ Error getting new articles count: $e');
      return 0;
    }
  }

  /// Stream để theo dõi số bài mới real-time (poll định kỳ mỗi 2 giây)
  /// Sử dụng distinct() để chỉ emit khi giá trị thay đổi
  static Stream<int> watchNewArticlesCount() {
    return Stream.periodic(const Duration(seconds: 2), (_) => null)
        .asyncMap((_) async {
      try {
        return await getNewArticlesCount();
      } catch (e) {
        print('⚠️ Stream error: $e');
        return 0;
      }
    })
        .distinct();
  }

  /// Đánh dấu tất cả bài viết đã đọc (đặt thời điểm xem = hiện tại)
  static Future<void> markAllAsRead() async {
    await markAsViewed();
  }

  /// Lưu ID bài viết đã đọc
  static Future<void> markArticleAsRead(String articleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readIds = prefs.getStringList(_readArticlesKey) ?? [];
      if (!readIds.contains(articleId)) {
        readIds.add(articleId);
        await prefs.setStringList(_readArticlesKey, readIds);
      }
    } catch (e) {
      print('❌ Error saving read article: $e');
    }
  }

  /// Đánh dấu tất cả bài viết hiện tại đã đọc
  static Future<void> markAllCurrentArticlesAsRead(List<String> articleIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readIds = prefs.getStringList(_readArticlesKey) ?? [];
      for (var id in articleIds) {
        if (!readIds.contains(id)) {
          readIds.add(id);
        }
      }
      await prefs.setStringList(_readArticlesKey, readIds);
    } catch (e) {
      print('❌ Error saving read articles: $e');
    }
  }

  /// Kiểm tra bài viết đã đọc chưa
  static Future<bool> isArticleRead(String articleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readIds = prefs.getStringList(_readArticlesKey) ?? [];
      return readIds.contains(articleId);
    } catch (e) {
      print('❌ Error checking read article: $e');
      return false;
    }
  }

  /// Lấy danh sách ID bài viết đã đọc
  static Future<List<String>> getReadArticleIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_readArticlesKey) ?? [];
    } catch (e) {
      print('❌ Error getting read articles: $e');
      return [];
    }
  }

  /// Lấy danh sách bài mới (cả diseases và healthy)
  /// Trả về List<Map> với keys: id, collection, title, subtitle, imageUrl, createdAt
  /// Nếu chưa từng xem, trả về tất cả bài active
  static Future<List<Map<String, dynamic>>> getNewArticles() async {
    try {
      final lastViewed = await _getLastViewedTime();
      final List<Map<String, dynamic>> articles = [];

      // Lấy bài mới từ diseases collection
      try {
        final diseasesQuery = await _firestore
            .collection('diseases')
            .where('isActive', isEqualTo: true)
            .get();

        for (var doc in diseasesQuery.docs) {
          final data = doc.data();
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          
          // Nếu chưa từng xem, hiển thị tất cả bài
          // Nếu đã xem, chỉ hiển thị bài mới sau lần xem cuối
          if (lastViewed == null || (createdAt != null && createdAt.isAfter(lastViewed))) {
            articles.add({
              'id': doc.id,
              'collection': 'diseases',
              'title': data['title'] ?? '',
              'subtitle': data['subtitle'] ?? '',
              'imageUrl': data['imageUrl'] ?? '',
              'content': data['content'] ?? '',
              'createdAt': createdAt ?? DateTime.now(),
              'isActive': data['isActive'] ?? true,
            });
          }
        }
      } catch (e) {
        print('⚠️ Error reading diseases collection: $e');
      }

      // Lấy bài mới từ healthy collection
      try {
        final healthyQuery = await _firestore
            .collection('healthy')
            .where('isActive', isEqualTo: true)
            .get();

        for (var doc in healthyQuery.docs) {
          final data = doc.data();
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          
          // Nếu chưa từng xem, hiển thị tất cả bài
          // Nếu đã xem, chỉ hiển thị bài mới sau lần xem cuối
          if (lastViewed == null || (createdAt != null && createdAt.isAfter(lastViewed))) {
            articles.add({
              'id': doc.id,
              'collection': 'healthy',
              'title': data['title'] ?? '',
              'subtitle': data['subtitle'] ?? '',
              'imageUrl': data['imageUrl'] ?? '',
              'content': data['content'] ?? '',
              'createdAt': createdAt ?? DateTime.now(),
              'isActive': data['isActive'] ?? true,
            });
          }
        }
      } catch (e) {
        print('⚠️ Error reading healthy collection: $e');
      }

      // Sắp xếp theo createdAt giảm dần (mới nhất trước)
      articles.sort((a, b) {
        final aTime = a['createdAt'] as DateTime;
        final bTime = b['createdAt'] as DateTime;
        return bTime.compareTo(aTime);
      });

      return articles;
    } catch (e) {
      print('❌ Error getting new articles: $e');
      return [];
    }
  }
}

