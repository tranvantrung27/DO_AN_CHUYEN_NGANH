import 'package:flutter/material.dart';
import '../../../widgets/cards/article_card.dart';

class HealthyTab extends StatefulWidget {
  const HealthyTab({super.key});

  @override
  State<HealthyTab> createState() => _HealthyTabState();
}

class _HealthyTabState extends State<HealthyTab> {
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
          imageUrl: 'https://via.placeholder.com/192.png?text=Healthy+$index',
          dateText: 'Thứ tư, 17/9/2025, 09:15 (GMT+7)',
          title: 'Sống khỏe #$index - mẹo dinh dưỡng, vận động, tinh thần',
          subtitle: '',
          sourceName: 'WHO',
          sourceAvatarUrl: 'https://via.placeholder.com/40.png?text=W',
          timeAgo: '${index + 3}h ago',
          onTap: () {},
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: 7,
      ),
    );
  }
}


