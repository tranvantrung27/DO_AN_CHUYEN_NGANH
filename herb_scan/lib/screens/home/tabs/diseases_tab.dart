import 'package:flutter/material.dart';
import '../../../widgets/cards/article_card.dart';
import '../../../services/DiseasesTab/disease_service.dart';
import '../../../models/DiseasesTab/disease_article.dart';
import 'details/disease_detail_screen.dart';

class DiseasesTab extends StatefulWidget {
  const DiseasesTab({super.key});

  @override
  State<DiseasesTab> createState() => _DiseasesTabState();
}

class _DiseasesTabState extends State<DiseasesTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: StreamBuilder<List<DiseaseArticle>>(
        stream: DiseaseService.getDiseasesStream(),
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
          final diseases = snapshot.data ?? [];

          // Không có dữ liệu
          if (diseases.isEmpty) {
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
              final disease = diseases[index];
              return ArticleCard(
                isLoading: false,
                imageUrl: disease.imageUrl,
                dateText: disease.dateText,
                title: disease.title,
                subtitle: disease.subtitle, // Hiển thị tiêu đề phụ
                sourceName: '', // Không hiển thị logo
                sourceAvatarUrl: '', // Không hiển thị logo
                timeAgo: disease.timeAgo,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiseaseDetailScreen(
                        article: disease,
                      ),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: diseases.length,
          );
        },
      ),
    );
  }
}
