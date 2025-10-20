enum FeedKind { rssOrAtom, json }

class SiteConfig {
  final String name;
  final String logoUrl;   // đặt logo ở đây
  final String feedUrl;   // chỉ cần link feed
  final FeedKind kind;

  const SiteConfig({
    required this.name,
    required this.logoUrl,
    required this.feedUrl,
    this.kind = FeedKind.rssOrAtom,
  });

  factory SiteConfig.fromJson(Map<String, dynamic> json) {
    return SiteConfig(
      name: json['name'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      feedUrl: json['feedUrl'] ?? '',
      kind: json['kind'] == 'json' ? FeedKind.json : FeedKind.rssOrAtom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'feedUrl': feedUrl,
      'kind': kind == FeedKind.json ? 'json' : 'rssOrAtom',
    };
  }
}
