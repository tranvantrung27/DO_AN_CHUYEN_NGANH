import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../../models/news/index.dart';
import '../../utils/news/date_utils.dart';

class GenericNewsService {
  /// Fetch tin tức từ bất kỳ nguồn nào (RSS/Atom/JSON)
  Future<List<Article>> fetch(SiteConfig site) async {
    try {
      final res = await http.get(
        Uri.parse(site.feedUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (compatible; HerbScan/1.0)',
          'Accept': 'application/rss+xml, application/atom+xml, application/json, text/xml, */*',
          'Accept-Charset': 'utf-8',
        },
      );
      
      if (res.statusCode != 200) {
        print('Failed to fetch ${site.name}: ${res.statusCode}');
        return [];
      }

      final ct = res.headers['content-type'] ?? '';
      String body = res.body;

      // Xử lý encoding UTF-8
      if (body.contains('Ã') || body.contains('áº') || body.contains('Bá»') || 
          body.contains('cÃ´ng') || body.contains('phÃ²ng')) {
        // Thử decode lại với UTF-8
        try {
          body = utf8.decode(res.bodyBytes);
        } catch (e) {
          print('Encoding error for ${site.name}: $e');
          // Fallback: thử fix một số ký tự phổ biến
          body = body
              .replaceAll('Ã¡', 'á')
              .replaceAll('Ã¢', 'â')
              .replaceAll('Ã¨', 'è')
              .replaceAll('Ã©', 'é')
              .replaceAll('Ã¬', 'ì')
              .replaceAll('Ã­', 'í')
              .replaceAll('Ã²', 'ò')
              .replaceAll('Ã³', 'ó')
              .replaceAll('Ã¹', 'ù')
              .replaceAll('Ãº', 'ú')
              .replaceAll('Ã½', 'ý')
              .replaceAll('Ã ', 'à')
              .replaceAll('Ã¨', 'è')
              .replaceAll('Ã©', 'é')
              .replaceAll('Ã¬', 'ì')
              .replaceAll('Ã­', 'í')
              .replaceAll('Ã²', 'ò')
              .replaceAll('Ã³', 'ó')
              .replaceAll('Ã¹', 'ù')
              .replaceAll('Ãº', 'ú')
              .replaceAll('Ã½', 'ý')
              .replaceAll('cÃ´ng', 'công')
              .replaceAll('phÃ²ng', 'phòng')
              .replaceAll('chá» ng', 'chống')
              .replaceAll('dá»ch', 'dịch')
              .replaceAll('phá»¥c', 'phục')
              .replaceAll('vá»¥', 'vụ')
              .replaceAll('Bá»', 'Bộ')
              .replaceAll('Y táº¿', 'Y tế');
        }
      }

      // Kiểm tra loại feed
      if (site.kind == FeedKind.json || 
          ct.contains('application/json') || 
          _looksLikeJson(body)) {
        return _parseJson(body, site);
      }
      
      return _parseRssAtom(body, site);
    } catch (e) {
      print('Error fetching ${site.name}: $e');
      return [];
    }
  }

  /// Kiểm tra xem có phải JSON không
  bool _looksLikeJson(String s) {
    final trimmed = s.trim();
    return trimmed.startsWith('{') || trimmed.startsWith('[');
  }

  /// Parse RSS/Atom feeds
  List<Article> _parseRssAtom(String xmlText, SiteConfig site) {
    try {
      final doc = XmlDocument.parse(xmlText);

      // Tìm items (RSS) hoặc entries (Atom)
      final items = doc.findAllElements('item').toList();
      final entries = items.isNotEmpty ? items : doc.findAllElements('entry').toList();

      return entries.map((node) {
        final title = (node.getElement('title')?.text ?? '').trim();
        final link = _extractLink(node);
        final pub = _extractPublishedDate(node);
        final image = _extractImage(node);

        return Article(
          title: title,
          link: link,
          imageUrl: image,
          publishedAtUtc: parsePublishedToUtc(pub),
          sourceName: site.name,
          sourceLogo: site.logoUrl,
        );
      }).where((a) => a.title.isNotEmpty && a.link.isNotEmpty).toList();
    } catch (e) {
      print('Error parsing RSS/Atom for ${site.name}: $e');
      return [];
    }
  }

  /// Extract link từ RSS/Atom node
  String _extractLink(XmlElement node) {
    // RSS: <link>url</link> hoặc <link href="url"/>
    final linkElement = node.getElement('link');
    if (linkElement != null) {
      return linkElement.getAttribute('href') ?? linkElement.text;
    }
    
    // Fallback: tìm guid
    final guid = node.findElements('guid').map((e) => e.text).firstWhere(
      (text) => text.isNotEmpty, 
      orElse: () => '',
    );
    
    return guid;
  }

  /// Extract published date từ RSS/Atom node
  String? _extractPublishedDate(XmlElement node) {
    return node.getElement('pubDate')?.text ??
           node.getElement('published')?.text ??
           node.getElement('updated')?.text;
  }

  /// Extract image từ RSS/Atom node
  String _extractImage(XmlElement node) {
    // RSS enclosure
    final enclosure = node.getElement('enclosure');
    if (enclosure != null && 
        (enclosure.getAttribute('type') ?? '').startsWith('image')) {
      return enclosure.getAttribute('url') ?? '';
    }

    // Media content
    final mediaContent = node.findAllElements('media:content');
    if (mediaContent.isNotEmpty) {
      return mediaContent.first.getAttribute('url') ?? '';
    }

    // Media thumbnail
    final mediaThumb = node.findAllElements('media:thumbnail');
    if (mediaThumb.isNotEmpty) {
      return mediaThumb.first.getAttribute('url') ?? '';
    }

    // Description image (fallback)
    final description = node.getElement('description')?.text ?? '';
    final imgMatch = RegExp(r'<img[^>]+src="([^"]+)"').firstMatch(description);
    if (imgMatch != null) {
      return imgMatch.group(1) ?? '';
    }

    return '';
  }

  /// Parse JSON feeds
  List<Article> _parseJson(String text, SiteConfig site) {
    try {
      final data = json.decode(text);

      // Tìm mảng items phổ biến
      final List list = data is List
          ? data
          : (data['items'] ?? 
             data['data'] ?? 
             data['results'] ?? 
             data['articles'] ?? 
             data['news'] ?? 
             data['posts'] ?? 
             []) as List;

      return list.map((e) {
        final map = e as Map<String, dynamic>;
        final title = (map['title'] ?? map['name'] ?? map['headline'] ?? '').toString();
        final link = (map['link'] ?? map['url'] ?? map['permalink'] ?? '').toString();
        final img = (map['image'] ?? 
                    map['thumbnail'] ?? 
                    map['thumb'] ?? 
                    map['cover'] ?? 
                    map['featured_image'] ?? 
                    '').toString();
        final pub = map['publish_time'] ?? 
                   map['published_at'] ?? 
                   map['datePublished'] ?? 
                   map['pubDate'] ?? 
                   map['created_at'] ?? 
                   map['updated_at'];

        return Article(
          title: title,
          link: link,
          imageUrl: img,
          publishedAtUtc: parsePublishedToUtc(pub),
          sourceName: site.name,
          sourceLogo: site.logoUrl,
        );
      }).where((a) => a.title.isNotEmpty && a.link.isNotEmpty).toList();
    } catch (e) {
      print('Error parsing JSON for ${site.name}: $e');
      return [];
    }
  }
}
