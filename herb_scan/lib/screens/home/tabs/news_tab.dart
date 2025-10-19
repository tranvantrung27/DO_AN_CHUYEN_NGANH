import 'package:flutter/material.dart';
import '../../../widgets/cards/article_card.dart';
import '../../../services/news/vnexpress_service.dart';
import '../../../models/articles/article.dart';
import '../../../utils/date_format_vn.dart';

class NewsTab extends StatefulWidget {
  const NewsTab({super.key});

  @override
  State<NewsTab> createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  bool _loading = true;
  List<Article> _articles = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });
    final service = VnExpressService();
    final data = await service.fetchHealthNews();
    if (!mounted) return;
    setState(() {
      _articles = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          if (_loading) {
            return const ArticleCard(
              isLoading: true,
              imageUrl: '',
              dateText: '',
              title: '',
              sourceName: '',
              sourceAvatarUrl: '',
              timeAgo: '',
            );
          }
          final a = _articles[index];
          final raw = a.publishedText.trim();
          String date = '';
          if (raw.isNotEmpty) {
            final formatted = formatVietnameseDateFromRss(raw).trim();
            date = formatted.isNotEmpty ? formatted : raw;
          }
          if (date.isEmpty) {
            date = 'Đang cập nhật';
          }
          return ArticleCard(
            imageUrl: a.imageUrl,
            dateText: date,
            title: a.title,
            sourceName: 'VnExpress',
            sourceAvatarUrl: 'https://s1.vnecdn.net/vnexpress/restruct/i/v9717/v2_2019/pc/graphics/logo.svg',
            timeAgo: '',
            showDateOnTop: true,
            onTap: () {},
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: _loading ? 8 : _articles.length,
      ),
    );
  }
}


