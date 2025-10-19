import 'package:flutter/material.dart';
import '../../../widgets/cards/article_card.dart';

class DiseasesTab extends StatefulWidget {
  const DiseasesTab({super.key});

  @override
  State<DiseasesTab> createState() => _DiseasesTabState();
}

class _DiseasesTabState extends State<DiseasesTab> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) => ArticleCard(
          isLoading: _loading,
          imageUrl: 'https://via.placeholder.com/192.png?text=Disease+$index',
          dateText: 'Thứ ba, 16/9/2025, 08:00 (GMT+7)',
          title: 'Các bệnh #$index - thông tin, triệu chứng, phòng ngừa',
          sourceName: 'Healthline',
          sourceAvatarUrl: 'https://via.placeholder.com/40.png?text=H',
          timeAgo: '${index + 2}h ago',
          onTap: () {},
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: 6,
      ),
    );
  }
}


