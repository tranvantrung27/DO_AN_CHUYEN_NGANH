import '../models/news/index.dart';

/// Cấu hình các nguồn tin tức
/// Chỉ cần thêm SiteConfig mới vào đây là có thêm nguồn tin
class NewsSources {
  static const List<SiteConfig> healthNews = [
    // 3 nguồn tin chính về y tế
    SiteConfig(
      name: 'VnExpress Sức Khỏe',
      logoUrl: 'https://s1.vnecdn.net/vnexpress/restruct/i/v9717/v2_2019/pc/graphics/logo.svg',
      feedUrl: 'https://vnexpress.net/rss/suc-khoe.rss',
      kind: FeedKind.rssOrAtom,
    ),
    SiteConfig(
      name: 'Sức Khỏe Đời Sống Y Tế',
      logoUrl: 'https://photo-baomoi.bmcdn.me/87bb25544116a848f107.png',
      feedUrl: 'https://suckhoedoisong.vn/rss/y-te.rss',
      kind: FeedKind.rssOrAtom,
    ),
    SiteConfig(
      name: 'Nhân Dân Y Tế',
      logoUrl: 'https://photo-baomoi.bmcdn.me/4e023e6de32e0a70533f.png',
      feedUrl: 'https://nhandan.vn/rss/y-te.rss',
      kind: FeedKind.rssOrAtom,
    ),
  ];

  static const List<SiteConfig> generalNews = [
    SiteConfig(
      name: 'VnExpress',
      logoUrl: 'https://s1.vnecdn.net/vnexpress/restruct/i/v9717/v2_2019/pc/graphics/logo.svg',
      feedUrl: 'https://vnexpress.net/rss/tin-moi-nhat.rss',
      kind: FeedKind.rssOrAtom,
    ),
    SiteConfig(
      name: 'Nhân Dân',
      logoUrl: 'https://photo-baomoi.bmcdn.me/4e023e6de32e0a70533f.png',
      feedUrl: 'https://nhandan.vn/rss/home.rss',
      kind: FeedKind.rssOrAtom,
    ),
    SiteConfig(
      name: 'Tuổi Trẻ',
      logoUrl: 'https://static-tuoi.tuoitre.vn/ttnew/r/ttnew/images/logo-tt.svg',
      feedUrl: 'https://tuoitre.vn/rss.htm',
      kind: FeedKind.rssOrAtom,
    ),
  ];

  /// Lấy tất cả nguồn tin sức khỏe
  static List<SiteConfig> get allHealthNews => healthNews;
  
  /// Lấy tất cả nguồn tin tổng hợp
  static List<SiteConfig> get allGeneralNews => generalNews;
  
  /// Lấy tất cả nguồn tin
  static List<SiteConfig> get allNews => [...healthNews, ...generalNews];
}
