import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../../models/HerbLibrary/herb_article.dart';
import '../cards/herb_card.dart';
import '../../screens/herballibrary/details/herb_detail_screen.dart';

/// Widget hiển thị danh sách các bài thuốc liên quan
class ScanRelatedRecipesList extends StatelessWidget {
  final List<HerbArticle> relatedRecipes;

  const ScanRelatedRecipesList({
    super.key,
    required this.relatedRecipes,
  });

  @override
  Widget build(BuildContext context) {
    if (relatedRecipes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Các bài thuốc liên quan',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        ...relatedRecipes.map((recipe) {
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            child: HerbCard(
              imageUrl: recipe.imageUrl,
              name: recipe.name,
              description: recipe.description,
              category: recipe.category,
              date: recipe.date,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HerbDetailScreen(article: recipe),
                  ),
                );
              },
              onBookmarkTap: () {
                // TODO: Implement bookmark functionality
              },
              onCategoryTap: (categoryName) {
                // TODO: Navigate to category screen
              },
            ),
          );
        }),
      ],
    );
  }
}

