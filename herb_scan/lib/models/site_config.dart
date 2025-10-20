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
}
