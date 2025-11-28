import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/herballibrary/herb_category_navigation.dart';
import '../../widgets/herballibrary/herb_library_header.dart';
import '../../widgets/cards/herb_card.dart';
import '../../services/HerbLibrary/herb_library_service.dart';
import '../../services/HerbLibrary/herb_category_service.dart';
import '../../models/HerbLibrary/herb_article.dart';
import '../../constants/herb_categories.dart';
import 'herb_search_screen.dart';
import 'details/herb_detail_screen.dart';

class HerbLibraryScreen extends StatefulWidget {
  final ValueNotifier<int>? tabChangeNotifier;
  
  const HerbLibraryScreen({super.key, this.tabChangeNotifier});

  @override
  State<HerbLibraryScreen> createState() => _HerbLibraryScreenState();
}

class _HerbLibraryScreenState extends State<HerbLibraryScreen> with WidgetsBindingObserver {
  String? _selectedCategoryId;
  String? _selectedCategoryName; // Store category name for filtering
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool _isVisible = true; // Track if screen is visible

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Listen to tab changes
    widget.tabChangeNotifier?.addListener(_handleTabChange);
  }


  void _handleTabChange() {
    // If HerbLibrary tab (index 3) is selected, reset filter
    if (widget.tabChangeNotifier?.value == 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resetFilter();
      });
    }
  }

  @override
  void dispose() {
    widget.tabChangeNotifier?.removeListener(_handleTabChange);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Reset filter when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _resetFilter();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if this is the visible route
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      final isCurrentRoute = modalRoute.isCurrent;
      if (isCurrentRoute && !_isVisible) {
        // Just became visible, reset filter
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _resetFilter();
        });
      }
      _isVisible = isCurrentRoute;
    }
  }

  void _resetFilter() {
    if (mounted) {
      setState(() {
        _selectedCategoryId = null;
        _selectedCategoryName = null;
      });
    }
  }

  // Public method to reset filter (called from parent)
  void resetFilter() {
    _resetFilter();
  }

  Future<void> _handleRefresh() async {
    // Reset filter when pull-to-refresh
    _resetFilter();
    // Wait a bit to show refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    // 1. Tính toán các kích thước cố định
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    // Chiều cao khi header thu nhỏ nhất (Hình 2)
    // = Status bar + Search Bar + một chút padding dưới đáy
    final minHeaderHeight = statusBarHeight + 60.h + 20.h; 

    // Chiều cao khi header mở to nhất (Hình 1)
    // = Chiều cao nhỏ + phần không gian cho Text (khoảng 60.h)
    final maxHeaderHeight = minHeaderHeight + 60.h;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ), // Enable scroll for RefreshIndicator
            slivers: [
            // 2. Sử dụng Header Widget riêng
            SliverPersistentHeader(
              pinned: true, // Để nó ghim lại khi cuộn
              delegate: HerbLibraryHeaderDelegate(
                minHeight: minHeaderHeight,
                maxHeight: maxHeaderHeight,
                statusBarHeight: statusBarHeight,
                onSearchTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HerbSearchScreen(),
                    ),
                  );
                },
              ),
            ),

            // 3. Nội dung bên dưới
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 20.h), 
                child: _buildCategorySection(),
              ),
            ),

            _buildContentSliver(),

            SliverToBoxAdapter(child: SizedBox(height: 30.h)),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return StreamBuilder<List<HerbCategory>>(
      stream: HerbCategoryService.getCategoriesStream(),
      builder: (context, snapshot) {
        final categories = snapshot.data ?? HerbCategories.defaultCategories;
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề "Triệu chứng thường gặp" với padding
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'Triệu chứng thường gặp',
                style: TextStyle(
                  color: const Color(0xFF090F47),
                  fontSize: 16.sp,
                  fontFamily: 'Overpass',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            // Category Navigation - trải dài hết màn hình
            HerbCategoryNavigation(
              categories: categories,
              selectedCategoryId: _selectedCategoryId,
              onCategorySelected: (categoryId) {
                setState(() {
                  _selectedCategoryId = categoryId;
                  // Find category name for filtering
                  final category = categories.firstWhere(
                    (cat) => cat.id == categoryId,
                    orElse: () => categories.first,
                  );
                  _selectedCategoryName = category.name;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildContentSliver() {
    return StreamBuilder<List<HerbArticle>>(
      stream: HerbLibraryService.getHerbsStream(
        category: _selectedCategoryName,
      ),
      builder: (context, snapshot) {
        // Lấy data từ snapshot (có thể là data cũ hoặc data mới)
        final herbs = snapshot.data ?? [];
        print('📱 Screen received ${herbs.length} herbs (loading: ${snapshot.connectionState == ConnectionState.waiting})');

        if (snapshot.hasError) {
          print('❌ Error loading herbs: ${snapshot.error}');
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(40.h),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      '❌ Lỗi: ${snapshot.error}',
                      style: TextStyle(fontSize: 14.sp, color: Colors.red),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Force rebuild
                        });
                      },
                      child: Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Nếu đang loading và chưa có data, hiển thị loading indicator
        if (snapshot.connectionState == ConnectionState.waiting && herbs.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(40.h),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        // Nếu không có data và không loading, hiển thị empty state
        if (herbs.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(40.h),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      '📭',
                      style: TextStyle(fontSize: 64.sp),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Chưa có bài thuốc nào',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildListDelegate([
            // Tiêu đề "Các bài viết liên quan"
            Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 16.h,
                bottom: 12.h,
              ),
              child: Text(
                'Các bài viết liên quan',
                style: TextStyle(
                  color: const Color(0xFF090F47),
                  fontSize: 16.sp,
                  fontFamily: 'Overpass',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Danh sách các card
            ...herbs.asMap().entries.map((entry) {
              final index = entry.key;
              final herb = entry.value;
              final hasRelatedArticles = herb.relatedArticles != null && 
                                        herb.relatedArticles!.isNotEmpty;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main herb card
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20.w,
                      right: 20.w,
                      bottom: hasRelatedArticles ? 16.h : (index < herbs.length - 1 ? 12.h : 0),
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
                        // TODO: Handle bookmark
                      },
                      onCategoryTap: (categoryName) {
                        // Filter by category khi tap vào category trong card
                        if (categoryName.isEmpty) return;
                        setState(() {
                          _selectedCategoryName = categoryName;
                          // Find category ID
                          HerbCategoryService.getCategories().then((categories) {
                            if (categories.isNotEmpty) {
                              try {
                                final foundCategory = categories.firstWhere(
                                  (HerbCategory cat) => cat.name == categoryName,
                                );
                                setState(() {
                                  _selectedCategoryId = foundCategory.id;
                                });
                              } catch (e) {
                                // Category not found, use first category as fallback
                                if (categories.isNotEmpty) {
                                  setState(() {
                                    _selectedCategoryId = categories.first.id;
                                  });
                                }
                              }
                            }
                          });
                        });
                      },
                    ),
                  ),
                  
                  // Related articles section
                  if (hasRelatedArticles) ...[
                    Padding(
                      padding: EdgeInsets.only(
                        left: 20.w,
                        bottom: 12.h,
                      ),
                      child: Text(
                        'Bài viết liên quan',
                        style: TextStyle(
                          color: const Color(0xFF090F47),
                          fontSize: 14.sp,
                          fontFamily: 'Overpass',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Related articles cards
                    FutureBuilder<List<HerbArticle>>(
                      future: HerbLibraryService.getRelatedHerbs(herb.relatedArticles!),
                      builder: (context, relatedSnapshot) {
                        if (relatedSnapshot.connectionState == ConnectionState.waiting) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        
                        final relatedHerbs = relatedSnapshot.data ?? [];
                        
                        if (relatedHerbs.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 20.w,
                            right: 20.w,
                            bottom: index < herbs.length - 1 ? 12.h : 0,
                          ),
                          child: Column(
                            children: relatedHerbs.asMap().entries.map((entry) {
                              final relatedIndex = entry.key;
                              final relatedHerb = entry.value;
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: relatedIndex < relatedHerbs.length - 1 ? 12.h : 0,
                                ),
                                child: HerbCard(
                                  imageUrl: relatedHerb.imageUrl,
                                  name: relatedHerb.name,
                                  description: relatedHerb.description,
                                  category: relatedHerb.category,
                                  date: relatedHerb.date,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HerbDetailScreen(article: relatedHerb),
                                      ),
                                    );
                                  },
                                  onBookmarkTap: () {
                                    // TODO: Handle bookmark
                                  },
                                  onCategoryTap: (categoryName) {
                                    if (categoryName.isEmpty) return;
                                    setState(() {
                                      _selectedCategoryName = categoryName;
                                      HerbCategoryService.getCategories().then((categories) {
                                        if (categories.isNotEmpty) {
                                          try {
                                            final foundCategory = categories.firstWhere(
                                              (HerbCategory cat) => cat.name == categoryName,
                                            );
                                            setState(() {
                                              _selectedCategoryId = foundCategory.id;
                                            });
                                          } catch (e) {
                                            // Category not found, use first category as fallback
                                            if (categories.isNotEmpty) {
                                              setState(() {
                                                _selectedCategoryId = categories.first.id;
                                              });
                                            }
                                          }
                                        }
                                      });
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              );
            }).toList(),
          ]),
        );
      },
    );
  }
}

