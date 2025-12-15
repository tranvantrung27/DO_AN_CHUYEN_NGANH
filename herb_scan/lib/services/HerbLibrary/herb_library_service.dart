import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/HerbLibrary/herb_article.dart';
import '../../data/mock_herb_data.dart';

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
      
      print(' Returning ${herbs.length} herbs');
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

  /// Tìm các bài thuốc liên quan theo tên lá và công dụng
  /// Tìm các bài thuốc có:
  /// - Tên chứa tên lá (ví dụ: "lá trầu không")
  /// - Công dụng liên quan (ví dụ: "răng miệng", "hôi miệng")
  /// Loại trừ bài thuốc hiện tại
  static Future<List<HerbArticle>> getRelatedRecipesByHerbName(
    String herbName,
    String usage, {
    String? excludeId,
    int limit = 5,
  }) async {
    try {
      // Lấy tất cả bài thuốc active từ Firestore
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();

      final allHerbs = snapshot.docs
          .map((doc) => HerbArticle.fromFirestore(doc))
          .toList();

      // Thêm mock data vào danh sách để tìm kiếm
      allHerbs.addAll(MockHerbData.mockHerbs);

      // Chuẩn hóa tên lá để tìm kiếm
      final normalizedHerbName = _normalizeText(herbName);
      final normalizedUsage = _normalizeText(usage);

      // Tách tên lá thành các từ khóa
      // Ví dụ: "Lá trầu không" -> ["lá trầu không", "trầu không", "trầu", "không"]
      // Ví dụ: "Lá Tía Tô" -> ["lá tía tô", "tía tô", "tía", "tô"]
      final herbKeywords = <String>[];
      
      // Thêm toàn bộ tên (bỏ "lá" ở đầu nếu có)
      String nameWithoutLa = normalizedHerbName;
      if (normalizedHerbName.startsWith('la ')) {
        nameWithoutLa = normalizedHerbName.substring(3).trim();
      }
      if (nameWithoutLa.isNotEmpty) {
        herbKeywords.add(nameWithoutLa); // "trầu không" hoặc "tía tô"
      }
      
      // Thêm từng từ riêng lẻ (bỏ qua "lá")
      final words = normalizedHerbName
          .split(RegExp(r'\s+'))
          .where((word) => word.length > 2 && word != 'la')
          .toList();
      herbKeywords.addAll(words);

      // Trích xuất các từ khóa công dụng từ usage
      // Ví dụ: "giải cảm, trị ho" -> ["cảm", "ho", "trị ho", "giải cảm"]
      final usageKeywords = _extractUsageKeywords(normalizedUsage);
      
      print('🔍 Tìm bài thuốc liên quan:');
      print('   Tên lá: $herbName -> Keywords: $herbKeywords');
      print('   Công dụng: $usage -> Keywords: $usageKeywords');

      // Tách thành 2 nhóm: bài thuốc có tên lá và bài thuốc có từ khóa công dụng
      final herbsWithHerbName = <HerbArticle>[];
      final herbsWithUsageKeywords = <HerbArticle>[];

      for (final herb in allHerbs) {
        // Loại trừ bài thuốc hiện tại
        if (excludeId != null && herb.id == excludeId) continue;

        final normalizedName = _normalizeText(herb.name);
        final normalizedDesc = _normalizeText(herb.description);
        final normalizedTags = herb.tags?.map((tag) => _normalizeText(tag)).join(' ') ?? '';

        // Kiểm tra 1: Có tên lá trong name, description hoặc tags (ưu tiên cao nhất)
        // Ưu tiên tìm cụm từ dài trước (ví dụ: "tía tô" trước "tía")
        bool hasHerbName = false;
        for (final keyword in herbKeywords) {
          // Tìm chính xác từ khóa (có thể là từ đơn hoặc cụm từ)
          // Sử dụng word boundary để tránh match sai (ví dụ: "tía" không match "tiêu")
          if (keyword.length > 3) {
            // Với từ dài, tìm chính xác
            if (normalizedName.contains(keyword) || 
                normalizedDesc.contains(keyword) || 
                normalizedTags.contains(keyword)) {
              hasHerbName = true;
              print('   ✅ Tìm thấy tên lá "$keyword" trong: ${herb.name}');
              break;
            }
          } else {
            // Với từ ngắn, tìm với word boundary
            final regex = RegExp(r'\b' + RegExp.escape(keyword) + r'\b');
            if (regex.hasMatch(normalizedName) || 
                regex.hasMatch(normalizedDesc) || 
                regex.hasMatch(normalizedTags)) {
              hasHerbName = true;
              print('   ✅ Tìm thấy tên lá "$keyword" trong: ${herb.name}');
              break;
            }
          }
        }

        if (hasHerbName) {
          herbsWithHerbName.add(herb);
          continue; // Không cần kiểm tra usage nữa nếu đã có tên lá
        }

        // Kiểm tra 2: Có từ khóa công dụng trong description (phần công dụng)
        // Chỉ tìm trong phần công dụng, không tìm trong toàn bộ description
        final usageSection = _extractUsageSection(normalizedDesc);
        bool hasUsageKeyword = false;
        
        if (usageSection.isNotEmpty && usageKeywords.isNotEmpty) {
          for (final keyword in usageKeywords) {
            // Tìm chính xác từ khóa trong phần công dụng
            if (keyword.length > 3) {
              // Với từ dài, tìm chính xác
              if (usageSection.contains(keyword)) {
                hasUsageKeyword = true;
                print('   ✅ Tìm thấy từ khóa công dụng "$keyword" trong: ${herb.name}');
                break;
              }
            } else {
              // Với từ ngắn, tìm với word boundary
              final regex = RegExp(r'\b' + RegExp.escape(keyword) + r'\b');
              if (regex.hasMatch(usageSection)) {
                hasUsageKeyword = true;
                print('   ✅ Tìm thấy từ khóa công dụng "$keyword" trong: ${herb.name}');
                break;
              }
            }
          }
        }

        if (hasUsageKeyword) {
          herbsWithUsageKeywords.add(herb);
        }
      }

      // Kết hợp kết quả: ưu tiên bài thuốc có tên lá trước
      final relatedHerbs = <HerbArticle>[];
      relatedHerbs.addAll(herbsWithHerbName);
      
      print('   📊 Kết quả: ${herbsWithHerbName.length} bài có tên lá, ${herbsWithUsageKeywords.length} bài có từ khóa công dụng');
      
      // Nếu chưa đủ, thêm từ nhóm có từ khóa công dụng
      if (relatedHerbs.length < limit && usageKeywords.isNotEmpty) {
        final remaining = limit - relatedHerbs.length;
        relatedHerbs.addAll(herbsWithUsageKeywords.take(remaining));
      }

      // Giới hạn số lượng kết quả
      final result = relatedHerbs.take(limit).toList();
      print('   ✅ Trả về ${result.length} bài thuốc liên quan');
      return result;
    } catch (e) {
      print('❌ Error fetching related recipes by herb name: $e');
      return [];
    }
  }

  /// Trích xuất các từ khóa công dụng từ text
  /// Ví dụ: "giải cảm, trị ho" -> ["cảm", "ho", "trị ho", "giải cảm"]
  static List<String> _extractUsageKeywords(String usage) {
    final keywords = <String>[];
    
    // Tách thành các từ (bỏ qua các từ không có nghĩa)
    final stopWords = ['công', 'dụng', 'tác', 'hiệu', 'quả', 'giúp', 'hỗ', 'trợ', 'điều', 'trị', 'giảm', 'làm'];
    final words = usage
        .split(RegExp(r'[\s,;.]+'))
        .where((word) => word.length > 2 && !stopWords.contains(word.toLowerCase()))
        .toList();

    // Thêm các từ đơn có nghĩa
    keywords.addAll(words);

    // Thêm các cụm từ phổ biến liên quan đến công dụng
    final commonUsagePhrases = [
      'răng miệng',
      'hôi miệng',
      'đau răng',
      'viêm nướu',
      'sâu răng',
      'tim mạch',
      'huyết áp',
      'tiêu hóa',
      'đau dạ dày',
      'viêm họng',
      'ho',
      'ho khan',
      'ho có đờm',
      'cảm',
      'cảm lạnh',
      'cảm cúm',
      'sổ mũi',
      'đau đầu',
      'mất ngủ',
      'da liễu',
      'mụn',
      'viêm da',
      'xương khớp',
      'đau khớp',
      'phong thấp',
      'tiết niệu',
      'viêm đường tiết niệu',
      'sỏi thận',
    ];

    // Kiểm tra xem có cụm từ nào trong usage không
    for (final phrase in commonUsagePhrases) {
      if (usage.contains(phrase)) {
        keywords.add(phrase);
        // Thêm các từ riêng lẻ trong cụm từ (nếu từ có nghĩa)
        keywords.addAll(
          phrase.split(' ').where((w) => w.length > 2 && !stopWords.contains(w.toLowerCase()))
        );
      }
    }

    // Loại bỏ trùng lặp và từ quá ngắn
    return keywords
        .where((k) => k.length > 2)
        .toSet()
        .toList();
  }

  /// Trích xuất phần công dụng từ description
  /// Chỉ lấy phần sau "công dụng:" để tìm kiếm chính xác hơn
  static String _extractUsageSection(String description) {
    final lowerDesc = description.toLowerCase();
    
    // Tìm "công dụng:" hoặc "công dụng"
    int usageIndex = lowerDesc.indexOf('công dụng:');
    int usageLength = 'công dụng:'.length;
    
    if (usageIndex == -1) {
      usageIndex = lowerDesc.indexOf('công dụng');
      usageLength = 'công dụng'.length;
    }
    
    if (usageIndex != -1) {
      final afterUsage = description.substring(usageIndex + usageLength).trim();
      // Tìm đến phần tiếp theo (Phương thuốc, Dùng ngoài, hoặc hết)
      final nextSectionPattern = RegExp(r'(phương thuốc|dùng ngoài|precautions|lưu ý|cách dùng)', caseSensitive: false);
      final nextSectionMatch = nextSectionPattern.firstMatch(afterUsage.toLowerCase());
      
      if (nextSectionMatch != null) {
        return afterUsage.substring(0, nextSectionMatch.start).trim().toLowerCase();
      }
      // Nếu không tìm thấy phần tiếp theo, lấy 500 ký tự đầu (đủ cho phần công dụng)
      if (afterUsage.length > 500) {
        return afterUsage.substring(0, 500).toLowerCase();
      }
      return afterUsage.toLowerCase();
    }
    
    // Nếu không tìm thấy "công dụng:", trả về rỗng để không tìm trong toàn bộ description
    return '';
  }

  /// Chuẩn hóa text để tìm kiếm (loại bỏ dấu, chuyển lowercase)
  static String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
        .replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e')
        .replaceAll(RegExp(r'[ìíịỉĩ]'), 'i')
        .replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
        .replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u')
        .replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y')
        .replaceAll(RegExp(r'[đ]'), 'd');
  }
}

