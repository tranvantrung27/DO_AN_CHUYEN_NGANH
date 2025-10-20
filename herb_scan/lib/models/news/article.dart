class Article {
  final String title;
  final String description;
  final String imageUrl;
  final String link;
  final DateTime? publishedAtUtc;
  final String sourceName;
  final String sourceLogo;

  Article({
    required this.title,
    this.description = '',
    required this.imageUrl,
    required this.link,
    this.publishedAtUtc,
    required this.sourceName,
    required this.sourceLogo,
  });

  // Legacy constructor for backward compatibility
  Article.legacy({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.link,
    required DateTime publishedAt,
    required this.sourceName,
  }) : publishedAtUtc = publishedAt.toUtc(),
       sourceLogo = '';

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      link: json['link'] ?? '',
      publishedAtUtc: json['publishedAtUtc'] != null 
          ? DateTime.parse(json['publishedAtUtc']) 
          : null,
      sourceName: json['sourceName'] ?? '',
      sourceLogo: json['sourceLogo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'link': link,
      'publishedAtUtc': publishedAtUtc?.toIso8601String(),
      'sourceName': sourceName,
      'sourceLogo': sourceLogo,
    };
  }
}
