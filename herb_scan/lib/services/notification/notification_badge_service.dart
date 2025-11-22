import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service để quản lý badge số bài mới trên notification icon
class NotificationBadgeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Lấy user ID hiện tại
  static String? get _currentUserId => _auth.currentUser?.uid;

  /// Tạo key duy nhất cho bài viết: "<collection>:<id>"
  static String _composeKey(String collection, String id) => '$collection:$id';

  /// Helpers: SharedPreferences keys theo từng user
  static String _prefsKey(String base) => '${base}_${_currentUserId ?? "anonymous"}';
  
  /// Lấy document reference cho user preferences
  static DocumentReference? get _userPrefsDoc {
    final userId = _currentUserId;
    if (userId == null) return null;
    return _firestore.collection('user_preferences').doc(userId);
  }

  /// Lấy thời điểm user xem notification lần cuối từ Firestore
  static Future<DateTime?> _getLastViewedTime() async {
    try {
      final docRef = _userPrefsDoc;
      if (docRef == null) {
        // Fallback local
        final prefs = await SharedPreferences.getInstance();
        final ts = prefs.getInt(_prefsKey('last_notification_viewed_time'));
        return ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : null;
      }
      
      final doc = await docRef.get();
      if (!doc.exists) {
        // Fallback local
        final prefs = await SharedPreferences.getInstance();
        final ts = prefs.getInt(_prefsKey('last_notification_viewed_time'));
        return ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : null;
      }
      
      final data = doc.data() as Map<String, dynamic>?;
      final timestamp = data?['lastNotificationViewedTime'] as Timestamp?;
      return timestamp?.toDate();
    } catch (e) {
      return null;
    }
  }

  /// Lấy thời điểm user xem notification lần cuối (public method)
  static Future<DateTime?> getLastViewedTime() async {
    return await _getLastViewedTime();
  }

  /// Lưu thời điểm user xem notification (hiện tại) vào Firestore
  static Future<void> markAsViewed() async {
    try {
      final docRef = _userPrefsDoc;
      final now = DateTime.now();

      // Local cache trước (cho UI phản hồi tức thì)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsKey('last_notification_viewed_time'), now.millisecondsSinceEpoch);

      // Remote (nếu có user)
      if (docRef != null) {
        await docRef.set({
          'lastNotificationViewedTime': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      // Ignore
    }
  }

  /// Đếm số bài mới từ cả diseases và healthy collections
  /// Bài mới = bài được tạo sau thời điểm user xem notification lần cuối
  /// Trừ đi những bài đã đọc
  /// Nếu chưa từng xem, đếm tất cả bài active là "mới"
  static Future<int> getNewArticlesCount() async {
    try {
      // Nếu user chưa đăng nhập, không hiển thị badge
      if (_currentUserId == null) {
        return 0;
      }
      
      final lastViewed = await _getLastViewedTime();
      final readIds = await getReadArticleIds();
      int count = 0;

      // Đếm bài mới từ diseases collection
      try {
        final diseasesQuery = await _firestore
            .collection('diseases')
            .where('isActive', isEqualTo: true)
            .get();

        int diseasesCount = 0;
        for (var doc in diseasesQuery.docs) {
          final articleId = doc.id;
          final data = doc.data();
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          final key = _composeKey('diseases', articleId);
          
          // Bỏ qua nếu đã đọc
          if (readIds.contains(key)) {
            continue;
          }
          
          // Nếu chưa từng xem, đếm tất cả bài active
          // Nếu đã xem, chỉ đếm bài mới sau lần xem cuối
          if (lastViewed == null || (createdAt != null && createdAt.isAfter(lastViewed))) {
            diseasesCount++;
          }
        }
        count += diseasesCount;
      } catch (e) {
        // Tiếp tục đếm từ healthy nếu có lỗi
      }

      // Đếm bài mới từ healthy collection
      try {
        final healthyQuery = await _firestore
            .collection('healthy')
            .where('isActive', isEqualTo: true)
            .get();

        int healthyCount = 0;
        for (var doc in healthyQuery.docs) {
          final articleId = doc.id;
          final data = doc.data();
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          final key = _composeKey('healthy', articleId);
          
          // Bỏ qua nếu đã đọc
          if (readIds.contains(key)) {
            continue;
          }
          
          // Nếu chưa từng xem, đếm tất cả bài active
          // Nếu đã xem, chỉ đếm bài mới sau lần xem cuối
          if (lastViewed == null || (createdAt != null && createdAt.isAfter(lastViewed))) {
            healthyCount++;
          }
        }
        count += healthyCount;
      } catch (e) {
        // Nếu lỗi permission, chỉ đếm từ diseases
      }

      return count;
    } catch (e) {
      return 0;
    }
  }

  /// Stream để theo dõi số bài mới real-time (poll định kỳ mỗi 2 giây)
  /// Tự động restart khi user đổi (listen vào auth state changes)
  /// Sử dụng distinct() để chỉ emit khi giá trị thay đổi
  static Stream<int> watchNewArticlesCount() {
    // Tạo stream: emit giá trị ban đầu ngay lập tức nếu có user
    final initialUser = _auth.currentUser;
    Stream<int> initialStream;
    if (initialUser != null) {
      initialStream = Stream.fromFuture(getNewArticlesCount().catchError((e) {
        return 0;
      }));
    } else {
      initialStream = Stream.value(0);
    }
    
    // Kết hợp với stream từ auth changes
    final authStream = _auth.authStateChanges()
        .where((user) => user != null)
        .asyncExpand((user) async* {
      // Emit giá trị ngay lập tức khi user đổi
      try {
        final count = await getNewArticlesCount();
        yield count;
      } catch (e) {
        yield 0;
      }
      
      // Sau đó poll định kỳ mỗi 2 giây
      await for (final _ in Stream.periodic(const Duration(seconds: 2))) {
        try {
          final count = await getNewArticlesCount();
          yield count;
        } catch (e) {
          yield 0;
        }
      }
    });
    
    // Kết hợp initial stream với auth stream
    return initialStream.asyncExpand((initialCount) {
      return Stream.value(initialCount).asyncExpand((_) => authStream);
    }).distinct();
  }

  /// Đánh dấu tất cả bài viết đã đọc (đặt thời điểm xem = hiện tại)
  static Future<void> markAllAsRead() async {
    await markAsViewed();
  }

  /// Lưu ID bài viết đã đọc vào Firestore (cần cả collection để tránh trùng ID)
  static Future<void> markArticleAsRead(String collection, String articleId) async {
    try {
      final docRef = _userPrefsDoc;
      
      final key = _composeKey(collection, articleId);

      // Local cache
      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getStringList(_prefsKey('read_articles_ids')) ?? [];
      if (!local.contains(key)) {
        local.add(key);
        await prefs.setStringList(_prefsKey('read_articles_ids'), local);
      }

      // Remote
      if (docRef != null) {
        await docRef.set({
          'readArticleIds': FieldValue.arrayUnion([key]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      // Ignore
    }
  }

  /// Đánh dấu tất cả bài viết hiện tại đã đọc vào Firestore
  /// Truyền vào danh sách key "<collection>:<id>"
  static Future<void> markAllCurrentArticlesAsReadKeys(List<String> articleKeys) async {
    try {
      final docRef = _userPrefsDoc;

      // Local cache
      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getStringList(_prefsKey('read_articles_ids')) ?? [];
      final merged = {...local, ...articleKeys}.toList();
      await prefs.setStringList(_prefsKey('read_articles_ids'), merged);
      
      // Remote
      if (docRef != null) {
        await docRef.set({
          'readArticleIds': FieldValue.arrayUnion(articleKeys),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      // Ignore
    }
  }

  /// Kiểm tra bài viết đã đọc chưa từ Firestore
  static Future<bool> isArticleRead(String collection, String articleId) async {
    try {
      final docRef = _userPrefsDoc;
      if (docRef == null) return false;
      
      final doc = await docRef.get();
      if (!doc.exists) return false;
      
      final data = doc.data() as Map<String, dynamic>?;
      final readIds = (data?['readArticleIds'] as List<dynamic>?)?.cast<String>() ?? [];
      return readIds.contains(_composeKey(collection, articleId));
    } catch (e) {
      return false;
    }
  }

  /// Lấy danh sách ID bài viết đã đọc từ Firestore
  static Future<List<String>> getReadArticleIds() async {
    try {
      final docRef = _userPrefsDoc;

      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getStringList(_prefsKey('read_articles_ids')) ?? [];

      if (docRef == null) return local;
      
      final doc = await docRef.get();
      if (!doc.exists) return local;
      
      final data = doc.data() as Map<String, dynamic>?;
      final remote = (data?['readArticleIds'] as List<dynamic>?)?.cast<String>() ?? [];

      // Hợp nhất remote và local
      return {...local, ...remote}.toList();
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_prefsKey('read_articles_ids')) ?? [];
    }
  }

  /// Lấy danh sách bài (cả diseases và healthy) đang active (bất kể lastViewed)
  /// Trả về List<Map> với keys: id, collection, title, subtitle, imageUrl, createdAt
  /// KHÔNG lọc theo đã đọc ở đây để UI có thể hiển thị mờ (isRead) dựa trên readIds
  /// Luôn trả về các bài active, sắp xếp mới nhất trước
  static Future<List<Map<String, dynamic>>> getNewArticles() async {
    try {
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
      } catch (e) {
        // Ignore
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
      } catch (e) {
        // Ignore
      }

      // Sắp xếp theo createdAt giảm dần (mới nhất trước)
      articles.sort((a, b) {
        final aTime = a['createdAt'] as DateTime;
        final bTime = b['createdAt'] as DateTime;
        return bTime.compareTo(aTime);
      });

      return articles;
    } catch (e) {
      return [];
    }
  }
}

