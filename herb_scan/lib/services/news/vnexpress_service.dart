import 'package:http/http.dart' as http;
import 'package:dart_rss/dart_rss.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

import '../../models/articles/article.dart';

class VnExpressService {
  static const String rssHealthAll = 'https://vnexpress.net/rss/suc-khoe.rss';
  static const String rssHealthNews = 'https://vnexpress.net/rss/suc-khoe/tin-tuc.rss';
  static const String rssDiseases = 'https://vnexpress.net/rss/suc-khoe/cac-benh.rss';
  static const String rssHealthy = 'https://vnexpress.net/rss/suc-khoe/song-khoe.rss';

  Future<List<Article>> fetchRss(String rssUrl) async {
    final response = await http.get(Uri.parse(rssUrl), headers: {
      'User-Agent': 'Mozilla/5.0 (Flutter) AppleWebKit/537.36 (KHTML, like Gecko)',
      'Accept-Language': 'vi,vi-VN;q=0.9,en-US;q=0.8',
      'Accept': 'application/rss+xml, application/xml; q=0.9, */*; q=0.8',
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
    });
    if (response.statusCode != 200) return [];
    final feed = RssFeed.parse(response.body);
    return feed.items.map((it) {
      final String title = it.title ?? '';
      final String link = it.link ?? '';
      final String description = _stripHtml(it.description ?? '');
      final String pubDate = it.pubDate ?? (it.dc?.date ?? '');
      final String image = _extractImageFromDescription(it.description) ??
          it.enclosure?.url ?? '';
      return Article(
        title: title,
        url: link,
        imageUrl: image,
        description: description,
        source: 'VnExpress',
        publishedText: pubDate,
      );
    }).where((a) => a.title.isNotEmpty && a.url.isNotEmpty).toList();
  }

  Future<List<Article>> fetchHealthNews() async {
    try {
      // 1) Luôn ưu tiên RSS để có pubDate ổn định
      List<Article> rss = await fetchRss(rssHealthNews);
      if (rss.isEmpty) {
        rss = await fetchRss(rssHealthAll);
      }
      if (rss.isEmpty) {
        // Nếu RSS hoàn toàn lỗi, dùng HTML như phương án cuối
        return await _fetchByHtml('https://vnexpress.net/suc-khoe/tin-tuc');
      }

      // 2) Enrich ảnh từ HTML (nếu RSS không có ảnh)
      final html = await _fetchByHtml('https://vnexpress.net/suc-khoe/tin-tuc');
      final Map<String, String> linkToImg = {
        for (final a in html) _normalizeLink(a.url): a.imageUrl
      };
      final Map<String, String> linkToTime = {
        for (final a in html) _normalizeLink(a.url): a.publishedText
      };
      final enriched = rss.map((a) {
        final key = _normalizeLink(a.url);
        final img = a.imageUrl.isEmpty ? (linkToImg[key] ?? '') : a.imageUrl;
        final pub = (a.publishedText.isEmpty || a.publishedText.trim().isEmpty)
            ? (linkToTime[key] ?? '')
            : a.publishedText;
        return Article(
          title: a.title,
          url: a.url,
          imageUrl: img,
          description: a.description,
          source: a.source,
          publishedText: pub,
        );
      }).toList();
      // 3) Với các bài vẫn thiếu thời gian, đọc trong trang chi tiết (giới hạn 12 bài để tránh chậm)
      final List<Article> withTime = List<Article>.from(enriched);
      final futures = <Future<void>>[];
      for (int i = 0; i < withTime.length && i < 30; i++) {
        if (withTime[i].publishedText.trim().isEmpty) {
          futures.add(() async {
            final t = await _fetchArticlePublishedTime(withTime[i].url);
            if (t.isNotEmpty) {
              withTime[i] = Article(
                title: withTime[i].title,
                url: withTime[i].url,
                imageUrl: withTime[i].imageUrl,
                description: withTime[i].description,
                source: withTime[i].source,
                publishedText: t,
              );
            }
          }());
        }
      }
      await Future.wait(futures);
      return withTime;
    } catch (_) {
      // Nếu có lỗi bất ngờ, trả HTML để vẫn hiển thị
      return await _fetchByHtml('https://vnexpress.net/suc-khoe/tin-tuc');
    }
  }

  Future<List<Article>> _fetchByHtml(String url) async {
    final res = await http.get(Uri.parse(url), headers: {
      'User-Agent': 'Mozilla/5.0 (Flutter)',
      'Accept-Language': 'vi,vi-VN;q=0.9,en-US;q=0.8',
    });
    if (res.statusCode != 200) return [];
    final dom.Document doc = html_parser.parse(res.body);
    final List<dom.Element> items = doc.querySelectorAll('article.item-news');
    return items.map((e) {
      final a = e.querySelector('h2.title-news a');
      final String image = _extractImageFromThumb(e);
      final desc = e.querySelector('p.description a');
      final time = e.querySelector('span.time');
      return Article(
        title: a?.text.trim() ?? '',
        url: a?.attributes['href'] ?? '',
        imageUrl: image,
        description: desc?.text.trim() ?? '',
        source: 'VnExpress',
        publishedText: time?.text.trim() ?? '',
      );
    }).where((e) => e.title.isNotEmpty && e.url.isNotEmpty).toList();
  }

  String? _extractImageFromDescription(String? html) {
    final match = RegExp(r'<img[^>]+src=\"([^\"]+)\"', caseSensitive: false)
        .firstMatch(html ?? '');
    return match?.group(1);
  }

  String _stripHtml(String html) => html.replaceAll(RegExp(r'<[^>]*>'), '').trim();

  String _extractImageFromThumb(dom.Element item) {
    // Try <picture><source srcset="... 1x, ... 2x">
    final srcSet = item.querySelector('div.thumb-art picture source')?.attributes['srcset'];
    if (srcSet != null && srcSet.isNotEmpty) {
      final first = srcSet.split(',').first.trim();
      final url = first.split(' ').first.trim();
      if (url.isNotEmpty) return url.replaceAll('&amp;', '&');
    }
    // Try <img data-src> then <img src>
    final img = item.querySelector('div.thumb-art img');
    if (img != null) {
      final dataSrc = img.attributes['data-src'] ?? img.attributes['data-original'];
      final src = dataSrc ?? img.attributes['src'] ?? '';
      if (src.isNotEmpty) return src.replaceAll('&amp;', '&');
    }
    return '';
  }

  String _normalizeLink(String url) {
    try {
      final u = Uri.parse(url);
      String path = u.path.toLowerCase();
      if (path.endsWith('/')) path = path.substring(0, path.length - 1);
      return path;
    } catch (_) {
      return url;
    }
  }

  Future<String> _fetchArticlePublishedTime(String url) async {
    try {
      final res = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'Mozilla/5.0 (Flutter)',
        'Accept-Language': 'vi,vi-VN;q=0.9,en-US;q=0.8',
      });
      if (res.statusCode != 200) return '';
      final dom.Document doc = html_parser.parse(res.body);
      String? time = doc.querySelector('span.date')?.text.trim();
      time ??= doc
          .querySelector('meta[property="article:published_time"]')
          ?.attributes['content']
          ?.trim();
      time ??= doc
          .querySelector('meta[itemprop="datePublished"]')
          ?.attributes['content']
          ?.trim();
      return time ?? '';
    } catch (_) {
      return '';
    }
  }
}


