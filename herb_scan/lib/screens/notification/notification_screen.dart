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
      // Lấy danh sách bài đã đọc (dạng key "collection:id") để hiển thị mờ
      final readKeys = await NotificationBadgeService.getReadArticleIds();
      setState(() {
        _allNotifications = articles.map((map) {
          final key = '${map['collection']}:${map['id']}';
          final isRead = readKeys.contains(key);
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
    // Đánh dấu tất cả bài hiện tại đã đọc (tất cả bài đang có trong danh sách)
    final articleKeys = _allNotifications
        .map((n) => {'collection': n.collection, 'id': n.id})
        .map((e) => '${e['collection']}:${e['id']}' )
        .toList();
    
    if (articleKeys.isEmpty) return;
    
    // Đánh dấu tất cả bài đã đọc trong Firestore
    await NotificationBadgeService.markAllCurrentArticlesAsReadKeys(articleKeys);
    // Cập nhật thời điểm xem cuối cùng
    await NotificationBadgeService.markAllAsRead();
    
    // Cập nhật UI - làm mờ tất cả card
    setState(() {
      _allNotifications = _allNotifications.map((n) => n.copyWith(isRead: true)).toList();
    });
    
    // Reload để đảm bảo đồng bộ với Firestore
    await _loadNotifications();
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
    // Nếu chưa đọc, đánh dấu đã đọc ngay lập tức
    if (!item.isRead) {
      await NotificationBadgeService.markArticleAsRead(item.collection, item.id);
      
      // Cập nhật UI ngay lập tức để card bị mờ đi
      if (mounted) {
        setState(() {
          _allNotifications = _allNotifications.map((n) {
            if (n.id == item.id) {
              return n.copyWith(isRead: true);
            }
            return n;
          }).toList();
        });
      }
    }
    
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
      
      // Sau khi quay lại, reload danh sách để đảm bảo đồng bộ với Firestore
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
    final filtered = _getFilteredNotifications();
    // Nhóm theo ngày (Thứ x, dd/MM)
    final Map<String, List<NotificationItem>> grouped = {};
    for (final item in filtered) {
      final key = _formatHeaderDate(item.createdAt);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final headers = grouped.keys.toList();

    // Tạo danh sách hiển thị: header + items
    final List<Widget> children = [];
    for (final header in headers) {
      children.add(Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
        child: Text(
          header,
          style: TextStyle(
            color: Colors.black,
            fontSize: 13.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
      ));

      final items = grouped[header]!;
      for (final n in items) {
        children.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: NotificationCard(
            imageUrl: n.imageUrl,
            title: n.title,
            createdAt: n.createdAt,
            isRead: n.isRead,
            onTap: () => _onNotificationTap(n),
            showBottomDivider: true,
          ),
        ));
      }
      // Khoảng cách giữa các nhóm
      children.add(SizedBox(height: 12.h));
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: AppColors.primaryGreen,
      child: ListView(
        padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
        children: children,
      ),
    );
  }

  String _formatHeaderDate(DateTime? dt) {
    if (dt == null) return '';
    final d = dt.toLocal();
    const days = [
      'Chủ nhật',
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
    ];
    final label = days[d.weekday % 7];
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$label, $dd/$mm';
  }
}

