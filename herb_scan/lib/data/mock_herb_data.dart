import '../models/HerbLibrary/herb_article.dart';

/// Mock data cho các loại lá cây để test scan
class MockHerbData {
  /// Danh sách mock herbs
  static List<HerbArticle> get mockHerbs => [
    _laTrauKhong,
    _laTiaTo,
  ];

  /// Lá Trầu Không
  static final HerbArticle _laTrauKhong = HerbArticle(
    id: 'mock_trau_khong', // ID này map với logic demo của bạn
    name: 'Lá Trầu Không',
    imageUrl: 'https://images.unsplash.com/photo-1504382103100-db7e92322d39?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx0cmFkaXRpb25hbCUyMG1lZGljaW5lJTIwaGVyYnN8ZW58MXx8fHwxNzY0NTc2NzU3fDA&ixlib=rb-4.1.0&q=80&w=1080',
    description: '''Lá trầu không là vị thuốc quý trong Đông y, có vị cay, tính ấm. Được sử dụng để điều trị nhiều bệnh từ ngoài da đến nội khoa, đặc biệt có tác dụng kháng viêm và sát khuẩn mạnh.

Công dụng: Kháng khuẩn, kháng nấm hiệu quả. Chữa ho, long đàm, viêm phế quản. Điều trị viêm nhiễm phụ khoa. Giảm đau khớp, phong thấp. Chữa lành vết thương, mụn nhọt. Đặc biệt có tác dụng giảm hôi miệng, hỗ trợ sức khỏe răng miệng.

Phương thuốc 1: Trị ho, long đàm...''',
    category: 'Răng miệng',
    date: 'Nov 26, 2024',
    tags: [
      'lá trầu không', 'trầu không', 'răng miệng', 'hôi miệng',
      'kháng khuẩn', 'viêm phế quản', 'phụ khoa', 'đau khớp', 'mụn nhọt',
    ],
    createdAt: DateTime(2024, 11, 26),
    isActive: true,

    // 🔥 CẬP NHẬT MỚI: Thêm 2 trường này để hiện Tags và Loa nói
    remedyTags: [
      'Kháng khuẩn', 
      'Trị ho & Long đàm', 
      'Trị viêm phụ khoa', 
      'Giảm đau khớp', 
      'Trị mụn nhọt'
    ],
    voiceSummary: "Lá trầu không có tính ấm, vị cay, thường dùng để kháng khuẩn, trị ho, viêm nhiễm phụ khoa và giảm đau khớp hiệu quả.",
    scientificName: "Piper betle L.",
  );

  /// Lá Tía Tô
  static final HerbArticle _laTiaTo = HerbArticle(
    id: 'mock_tia_to',
    name: 'Lá Tía Tô',
    imageUrl: 'https://images.unsplash.com/photo-1710596220294-3f88dfe02fd8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxncmVlbiUyMGxlYWYlMjBwbGFudHxlbnwxfHx8fDE3NjQ1NzY3NTd8MA&ixlib=rb-4.1.0&q=80&w=1080',
    description: '''Tía tô là loại thảo dược có mùi thơm đặc trưng, vị cay, tính ấm. Rất tốt cho hệ tiêu hóa và hô hấp, thường dùng để giải độc hải sản.

Công dụng: Giải cảm, trị ho khan, sổ mũi. Giải độc hải sản, cá, cua. Hỗ trợ tiêu hóa, giảm buồn nôn. Kháng dị ứng, chống viêm...''',
    category: 'Tim mạch',
    date: 'Nov 24, 2024',
    tags: [
      'lá tía tô', 'tía tô', 'tim mạch', 'huyết áp',
      'giải cảm', 'ho', 'tiêu hóa', 'giải độc', 'ốm nghén',
    ],
    createdAt: DateTime(2024, 11, 24),
    isActive: true,

    // 🔥 CẬP NHẬT MỚI
    remedyTags: [
      'Giải cảm', 
      'Trị ho khan', 
      'Giải độc hải sản', 
      'Hỗ trợ tiêu hóa', 
      'Trị ốm nghén'
    ],
    voiceSummary: "Lá tía tô có tính ấm, vị cay, đặc biệt hiệu quả trong việc giải cảm, trị ho, giải độc hải sản và an thai cho bà bầu.",
    scientificName: "Perilla frutescens",
  );

  /// Tìm herb theo tên (không phân biệt hoa thường)
  static HerbArticle? findByName(String name) {
    final normalizedName = name.toLowerCase().trim();
    try {
      return mockHerbs.firstWhere(
        (herb) => herb.name.toLowerCase().contains(normalizedName) ||
                  normalizedName.contains(herb.name.toLowerCase()),
      );
    } catch (e) {
      return null;
    }
  }

  /// Lấy herb theo ID
  static HerbArticle? findById(String id) {
    try {
      return mockHerbs.firstWhere((herb) => herb.id == id);
    } catch (e) {
      return null;
    }
  }
}