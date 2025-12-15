import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../../widgets/cards/herb_card.dart';
import '../../services/HerbLibrary/herb_library_service.dart';
import '../../models/HerbLibrary/herb_article.dart';
import '../../utils/app_utils.dart';
import 'details/herb_detail_screen.dart';

class HerbSearchScreen extends StatefulWidget {
  const HerbSearchScreen({super.key});

  @override
  State<HerbSearchScreen> createState() => _HerbSearchScreenState();
}

class _HerbSearchScreenState extends State<HerbSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<HerbArticle> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query != _searchQuery) {
      setState(() {
        _searchQuery = query;
        _isSearching = true;
      });
      _performSearch(query);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    try {
      // Lấy tất cả herbs và filter ở client side
      // (Firestore không hỗ trợ full-text search tốt, nên filter ở client)
      final allHerbs = await HerbLibraryService.getHerbs();
      
      // Normalize search query (remove diacritics and lowercase)
      final searchNormalized = AppUtils.removeVietnameseDiacritics(query.toLowerCase().trim());
      
      if (searchNormalized.isEmpty) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        return;
      }
      
      final results = allHerbs.where((herb) {
        // Normalize all fields for comparison (remove diacritics)
        final nameNormalized = AppUtils.removeVietnameseDiacritics(herb.name.toLowerCase());
        final descNormalized = AppUtils.removeVietnameseDiacritics(herb.description.toLowerCase());
        final categoryNormalized = herb.category != null 
            ? AppUtils.removeVietnameseDiacritics(herb.category!.toLowerCase())
            : '';
        
        // Check if search query matches in any field (normalized comparison)
        final nameMatch = nameNormalized.contains(searchNormalized);
        final descMatch = descNormalized.contains(searchNormalized);
        final categoryMatch = categoryNormalized.isNotEmpty && 
                             categoryNormalized.contains(searchNormalized);
        
        return nameMatch || descMatch || categoryMatch;
      }).toList();

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      print('❌ Search error: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Container(
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x11000000),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Tìm bài thuốc theo triệu chứng (ho, mất ngủ…)',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Image.asset(
                  'assets/icons/sreach.png',
                  width: 20.w,
                  height: 20.w,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 10.h,
                ),
              ),
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(
              'Đang tìm kiếm...',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'Nhập từ khóa để tìm kiếm',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tìm theo tên, mô tả hoặc triệu chứng',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '📭',
              style: TextStyle(fontSize: 64.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'Không tìm thấy kết quả',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Thử tìm kiếm với từ khóa khác',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final herb = _searchResults[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < _searchResults.length - 1 ? 12.h : 0,
          ),
          child: HerbCard(
            imageUrl: herb.imageUrl,
            name: herb.name,
            description: herb.description,
            category: herb.category,
            date: herb.date,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HerbDetailScreen(article: herb),
                ),
              );
            },
            onBookmarkTap: () {

            },
            onCategoryTap: (categoryName) {
  
            },
          ),
        );
      },
    );
  }
}

