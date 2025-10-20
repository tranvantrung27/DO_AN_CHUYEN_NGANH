# Hệ Thống Tin Tức "Plug-and-Play"

## Tổng Quan

Hệ thống tin tức được thiết kế theo kiến trúc "cắm-là-chạy" - chỉ cần cấu hình link RSS và logo là có thể hiển thị tin từ bất kỳ trang báo nào.

**Tích hợp vào NewsTab trong HomeScreen** - Không tạo màn hình riêng biệt.

## Cấu Trúc Thư Mục

```
lib/
├── models/news/           # Models cho tin tức
│   ├── article.dart      # Model Article
│   ├── site_config.dart  # Model SiteConfig
│   └── index.dart        # Export
├── services/news/         # Services xử lý tin tức
│   ├── generic_news_service.dart  # Service chung
│   └── index.dart        # Export
├── widgets/news/          # Widgets hiển thị
│   ├── news_list.dart    # Widget danh sách tin
│   └── index.dart        # Export
├── screens/home/tabs/     # Tích hợp vào NewsTab
│   └── news_tab.dart     # Tab tin tức với hệ thống plug-and-play
├── utils/news/            # Utilities
│   ├── date_utils.dart    # Xử lý ngày tháng
│   └── index.dart        # Export
└── config/
    └── news_sources.dart # Cấu hình nguồn tin
```

## Cách Thêm Nguồn Tin Mới

### 1. Thêm vào `lib/config/news_sources.dart`

```dart
SiteConfig(
  name: 'Tên Báo',
  logoUrl: 'https://example.com/logo.png',
  feedUrl: 'https://example.com/rss.xml',
  kind: FeedKind.rssOrAtom, // hoặc FeedKind.json
),
```

### 2. Hỗ Trợ Các Loại Feed

- **RSS/Atom**: Tự động detect từ content-type hoặc cấu hình
- **JSON**: Cần set `kind: FeedKind.json`

### 3. Parser Tự Động

Service tự động tìm các field phổ biến:
- **Title**: `title`, `name`, `headline`
- **Link**: `link`, `url`, `permalink`
- **Image**: `image`, `thumbnail`, `thumb`, `cover`, `featured_image`
- **Date**: `publish_time`, `published_at`, `datePublished`, `pubDate`

## Tính Năng

### ✅ Đã Hoàn Thành

- [x] Models cho Article và SiteConfig
- [x] GenericNewsService xử lý RSS/Atom/JSON
- [x] Parser ngày tháng đa dạng (timestamp, ISO, RSS, VN format)
- [x] NewsList widget với skeleton loading
- [x] NewsScreen với TabView và PageView
- [x] Tích hợp vào navigation chính
- [x] URL launcher cho mở link
- [x] Error handling và empty state
- [x] Refresh toàn bộ danh sách

### 🔄 Có Thể Mở Rộng

- [ ] Cache tin tức offline
- [ ] Bookmark tin tức yêu thích
- [ ] Tìm kiếm tin tức
- [ ] Filter theo chủ đề
- [ ] Push notification cho tin mới
- [ ] Share tin tức

## Sử Dụng

### Trong NewsTab

Hệ thống đã được tích hợp sẵn vào `lib/screens/home/tabs/news_tab.dart`. Chỉ cần thêm nguồn tin mới vào `lib/config/news_sources.dart` là tự động có trong NewsTab.

## Lợi Ích

1. **Không phải code mỗi trang**: Thêm báo mới = thêm `SiteConfig`
2. **Parser chung**: Tự động xử lý RSS/Atom/JSON
3. **Thời gian chuẩn**: Lưu UTC, hiển thị theo local
4. **UI nhất quán**: Skeleton loading, error handling
5. **Dễ bảo trì**: Cấu trúc thư mục rõ ràng

## Dependencies

```yaml
dependencies:
  http: ^1.5.0          # HTTP requests
  xml: ^6.5.0           # XML parsing
  url_launcher: ^6.3.1  # Open URLs
  intl: ^0.19.0         # Date formatting
  cached_network_image: ^3.4.1  # Image caching
  shimmer: ^3.0.0       # Loading effects
```
