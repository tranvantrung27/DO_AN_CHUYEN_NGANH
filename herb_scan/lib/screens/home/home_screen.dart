import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../../widgets/content_navigation_bar.dart';
import '../../widgets/cards/article_card.dart';
import '../../services/notification/notification_badge_service.dart';
import 'tabs/news_tab.dart';
import 'tabs/diseases_tab.dart';
import 'tabs/healthy_tab.dart';
import '../notification/notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _initialLoading = false);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: Column(
          children: [
            // TOPBAR (3 phần)
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1) Header: title + notice icon
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'HerbScan',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 32.sp,
                            fontFamily: 'Libre Franklin',
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            letterSpacing: 0.64,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          // KHÔNG markAsViewed ở đây - chỉ mark khi user thực sự đọc
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(6.r),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 42.w,
                              height: 42.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0x19000000),
                                    blurRadius: 10,
                                    offset: const Offset(0, 0),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/icons/notice.png',
                                width: 40.w,
                                height: 40.h,
                              ),
                            ),
                            // Badge hiển thị số bài mới
                            StreamBuilder<int>(
                              stream: NotificationBadgeService.watchNewArticlesCount(),
                              initialData: 0,
                              builder: (context, snapshot) {
                                final count = snapshot.data ?? 0;
                                print('🔔 StreamBuilder: count=$count, hasError=${snapshot.hasError}, connectionState=${snapshot.connectionState}');
                                if (snapshot.hasError) {
                                  print('🔔 StreamBuilder error: ${snapshot.error}');
                                }
                                if (count <= 0) {
                                  return const SizedBox.shrink();
                                }
                                return Positioned(
                                  right: -4.w,
                                  top: -4.h,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: count > 9 ? 4.w : 6.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(count > 9 ? 8.r : 20.r),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 16.w,
                                      minHeight: 16.h,
                                    ),
                                    child: Text(
                                      count > 99 ? '99+' : count.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.sp,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  // 2) Search bar
                  Container(
                    width: double.infinity,
                    height: 48.h,
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        width: 1,
                        color: const Color(0xFF4E4B66),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: 24.w,
                          color: const Color(0xFFA0A3BD),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Search',
                            style: TextStyle(
                              color: const Color(0xFFA0A3BD),
                              fontSize: 14.sp,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                              letterSpacing: 0.12,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.mic,
                          size: 24.w,
                          color: const Color(0xFFA0A3BD),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  // 3) Content navigation bar
                  SizedBox(
                    height: 50.h,
                    child: ContentNavigationBar(
                      currentIndex: _tabIndex,
                      onChanged: (i) => setState(() => _tabIndex = i),
                    ),
                  ),
                ],
              ),
            ),
            
            // PHẦN NỘI DUNG Ở GIỮA MÀN HÌNH
            Expanded(
              child: _initialLoading
                  ? ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: 6,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                    )
                  : IndexedStack(
                      index: _tabIndex,
                      children: const [
                        NewsTab(),
                        DiseasesTab(),
                        HealthyTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

}
