import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../../services/notification/notification_badge_service.dart';
import '../../models/notification_item.dart';
import '../../widgets/cards/notification_card.dart';
import '../../widgets/notification_tab_navigation.dart';
import '../home/tabs/details/disease_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> _allNotifications = []; // Tất cả notifications
  bool _isLoading = true;
  int _selectedTab = 0; // 0: Tất cả, 1: Các bệnh, 2: Sống khỏe

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final articles = await NotificationBadgeService.getNewArticles();
      final readIds = await NotificationBadgeService.getReadArticleIds();
      setState(() {
        _allNotifications = articles.map((map) {
          final isRead = readIds.contains(map['id']);
          return NotificationItem.fromMap(map, isRead: isRead);
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading notifications: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllAsRead() async {
    // Đánh dấu tất cả bài hiện tại đã đọc (chỉ những bài đang hiển thị)
    final filteredNotifications = _getFilteredNotifications();
    final articleIds = filteredNotifications.map((n) => n.id).toList();
    await NotificationBadgeService.markAllCurrentArticlesAsRead(articleIds);
    await NotificationBadgeService.markAllAsRead();
    
    // Cập nhật UI - làm mờ tất cả card
    setState(() {
      _allNotifications = _allNotifications.map((n) {
        if (articleIds.contains(n.id)) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
    });
  }

  /// Lọc notifications theo tab hiện tại
  List<NotificationItem> _getFilteredNotifications() {
    switch (_selectedTab) {
      case 0: // Tất cả
        return _allNotifications;
      case 1: // Các bệnh
        return _allNotifications.where((n) => n.collection == 'diseases').toList();
      case 2: // Sống khỏe
        return _allNotifications.where((n) => n.collection == 'healthy').toList();
      default:
        return _allNotifications;
    }
  }

  Future<void> _onNotificationTap(NotificationItem item) async {
    // Đánh dấu bài này đã đọc
    await NotificationBadgeService.markArticleAsRead(item.id);
    
    // Navigate to detail screen
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiseaseDetailScreen(
            article: item.toDiseaseArticle(),
          ),
        ),
      );
      
      // Sau khi quay lại, reload danh sách để cập nhật isRead
      _loadNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Thông báo',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            height: 1.50,
            letterSpacing: 0.12,
          ),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _getFilteredNotifications().isNotEmpty ? _markAllAsRead : null,
              child: Text(
                'Đọc tất cả',
                style: TextStyle(
                  color: _getFilteredNotifications().isNotEmpty 
                      ? Colors.blue 
                      : Colors.grey,
                  fontSize: 14.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Navigation tabs dưới topbar
            NotificationTabNavigation(
              currentIndex: _selectedTab,
              onChanged: (index) {
                setState(() {
                  _selectedTab = index;
                });
              },
            ),
            // Nội dung
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    )
                  : _getFilteredNotifications().isEmpty
                      ? _buildEmptyState()
                      : _buildNotificationsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: 430.w,
                maxHeight: 430.h,
              ),
              child: Image.asset(
                'assets/icons/notification.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 40.h),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Chưa có thông báo mới',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                    letterSpacing: 0.12,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Bạn chưa có thông báo mới nào',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                    letterSpacing: 0.12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    final filteredNotifications = _getFilteredNotifications();
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: AppColors.primaryGreen,
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: filteredNotifications.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final notification = filteredNotifications[index];
          return NotificationCard(
            imageUrl: notification.imageUrl,
            title: notification.title,
            createdAt: notification.createdAt,
            isRead: notification.isRead,
            onTap: () => _onNotificationTap(notification),
          );
        },
      ),
    );
  }
}

