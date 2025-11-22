import 'package:flutter/material.dart';
import '../../../widgets/cards/article_card.dart';
import '../../../services/HealthyTab/healthy_service.dart';
import '../../../models/HealthyTab/healthy_article.dart';
import 'details/healthy_detail_screen.dart';

class HealthyTab extends StatefulWidget {
  const HealthyTab({super.key});

  @override
  State<HealthyTab> createState() => _HealthyTabState();
}

class _HealthyTabState extends State<HealthyTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: StreamBuilder<List<HealthyArticle>>(
        stream: HealthyService.getHealthyStream(),
        builder: (context, snapshot) {
          // Đang tải dữ liệu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) => const ArticleCard(
                isLoading: true,
                imageUrl: '',
                dateText: '',
                title: '',
                subtitle: '',
                sourceName: '',
                sourceAvatarUrl: '',
                timeAgo: '',
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: 3,
            );
          }

          // Có lỗi
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Không thể tải dữ liệu',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // Lấy dữ liệu thành công
          final healthyArticles = snapshot.data ?? [];

          // Không có dữ liệu
          if (healthyArticles.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.article_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Chưa có bài viết nào',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Chúng tôi sẽ sớm cập nhật các bài viết liên quan',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // Hiển thị danh sách bài viết
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              // Hiển thị message ở cuối danh sách
              if (index == healthyArticles.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    children: [
                      Text(
                        'Bạn đã xem hết bài viết.\nChúng tôi sẽ sớm cập nhật các bài viết mới',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              final healthy = healthyArticles[index];
              return ArticleCard(
                isLoading: false,
                imageUrl: healthy.imageUrl,
                dateText: healthy.dateText,
                title: healthy.title,
                subtitle: healthy.subtitle, // Hiển thị tiêu đề phụ
                sourceName: '', // Không hiển thị logo
                sourceAvatarUrl: '', // Không hiển thị logo
                timeAgo: healthy.timeAgo,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HealthyDetailScreen(
                        article: healthy,
                      ),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (_, index) {
              // Không hiển thị separator sau item cuối cùng (message)
              if (index == healthyArticles.length - 1) {
                return const SizedBox.shrink();
              }
              return const SizedBox(height: 12);
            },
            itemCount: healthyArticles.length + 1, // +1 cho message ở cuối
          );
        },
      ),
    );
  }
}


