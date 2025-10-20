import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../widgets/cards/article_card.dart';
import '../../../models/news/index.dart';
import '../../../services/news/index.dart';
import '../../../utils/news/date_utils.dart';
import '../../../config/news_sources.dart';

class NewsTab extends StatefulWidget {
  const NewsTab({super.key});

  @override
  State<NewsTab> createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  bool _loading = true;
  List<Article> _articles = [];
  String? _error;

  // Sử dụng nguồn tin sức khỏe từ config
  static final List<SiteConfig> _newsSources = NewsSources.allHealthNews;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    
    setState(() {
      _loading = true;
      _error = null;
    });
    
    try {
      final service = GenericNewsService();
      final articlesBySource = <String, List<Article>>{};
      
      // Fetch từ tất cả nguồn và nhóm theo nguồn
      for (final source in _newsSources) {
        try {
          final data = await service.fetch(source);
          if (data.isNotEmpty) {
            articlesBySource[source.name] = data;
          }
        } catch (e) {
          print('Error fetching from ${source.name}: $e');
          // Tiếp tục với nguồn khác nếu có lỗi
        }
      }
      
      // Xen kẽ đều giữa các nguồn
      final mixedArticles = _interleaveArticles(articlesBySource);
      
      if (!mounted) return;
      
      setState(() {
        _articles = mixedArticles;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Xen kẽ đều các bài viết từ các nguồn khác nhau
  List<Article> _interleaveArticles(Map<String, List<Article>> articlesBySource) {
    final result = <Article>[];
    final sources = articlesBySource.keys.toList();
    
    if (sources.isEmpty) return result;
    
    // Tạo danh sách iterator cho mỗi nguồn
    final iterators = <String, Iterator<Article>>{};
    for (final source in sources) {
      iterators[source] = articlesBySource[source]!.iterator;
    }
    
    // Xen kẽ theo vòng tròn
    int currentSourceIndex = 0;
    bool hasMoreArticles = true;
    
    while (hasMoreArticles) {
      hasMoreArticles = false;
      
      // Duyệt qua tất cả nguồn theo thứ tự
      for (int i = 0; i < sources.length; i++) {
        final sourceIndex = (currentSourceIndex + i) % sources.length;
        final source = sources[sourceIndex];
        final iterator = iterators[source]!;
        
        if (iterator.moveNext()) {
          result.add(iterator.current);
          hasMoreArticles = true;
        }
      }
      
      currentSourceIndex = (currentSourceIndex + 1) % sources.length;
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => const ArticleCard(
          isLoading: true,
          imageUrl: '',
          dateText: '',
          title: '',
          sourceName: '',
          sourceAvatarUrl: '',
          timeAgo: '',
        ),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không thể tải tin tức',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    
    if (_articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có tin tức',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chưa có tin tức từ các nguồn',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final article = _articles[index];
        final date = formatDateForDisplay(article.publishedAtUtc);
        
        return ArticleCard(
          imageUrl: article.imageUrl,
          dateText: date,
          title: article.title,
          sourceName: article.sourceName,
          sourceAvatarUrl: article.sourceLogo,
          timeAgo: '',
          showDateOnTop: true,
          onTap: () => _openArticle(article),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: _articles.length,
    );
  }

  void _openArticle(Article article) async {
    try {
      final uri = Uri.parse(article.link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể mở liên kết: ${article.link}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi mở liên kết: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}


