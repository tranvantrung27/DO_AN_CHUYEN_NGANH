import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../screens/settings/details/personal_info_screen.dart';

/// Widget hiển thị thông tin người dùng (avatar + tên + email)
class UserProfileCard extends StatefulWidget {
  final User? user;

  const UserProfileCard({
    super.key,
    required this.user,
  });

  @override
  State<UserProfileCard> createState() => _UserProfileCardState();
}

class _UserProfileCardState extends State<UserProfileCard> {
  String? _displayName;
  String? _email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    String? displayName;
    String? email;
    
    // Ưu tiên lấy từ Firebase Auth
    if (widget.user != null) {
      displayName = widget.user!.displayName;
      email = widget.user!.email;
    }
    
    // Nếu không có, lấy từ Firestore
    if (displayName == null || displayName.isEmpty || email == null) {
      try {
        String? userId = widget.user?.uid;
        if (userId == null) {
          // Lấy từ SharedPreferences nếu đăng nhập bằng số điện thoại
          final prefs = await SharedPreferences.getInstance();
          userId = prefs.getString('current_user_id');
        }
        
        if (userId != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
          
          if (userDoc.exists) {
            final userData = userDoc.data();
            displayName = displayName ?? userData?['displayName']?.toString();
            email = email ?? userData?['email']?.toString();
          }
        }
      } catch (e) {
        print('Error loading user data from Firestore: $e');
      }
    }
    
    // Nếu vẫn không có, lấy từ email hoặc phoneNumber
    if (displayName == null || displayName.isEmpty) {
      if (email != null && email.isNotEmpty) {
        displayName = email.split('@')[0];
      } else {
        // Lấy từ Firestore phoneNumber nếu có
        try {
          String? userId = widget.user?.uid;
          if (userId == null) {
            final prefs = await SharedPreferences.getInstance();
            userId = prefs.getString('current_user_id');
          }
          
          if (userId != null) {
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();
            
            if (userDoc.exists) {
              final userData = userDoc.data();
              displayName = userData?['phoneNumber']?.toString() ?? 'Người dùng';
            }
          }
        } catch (e) {
          displayName = 'Người dùng';
        }
      }
    }
    
    setState(() {
      _displayName = displayName ?? 'Người dùng';
      _email = email ?? '';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = _isLoading ? 'Đang tải...' : (_displayName ?? 'Người dùng');
    final avatarUrl = widget.user?.photoURL;
    final userEmail = _email ?? '';

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PersonalInfoScreen(),
          ),
        );
        // Reload lại để cập nhật UI khi quay lại
        _loadUserData();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 4,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
                image: avatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(avatarUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: avatarUrl == null
                  ? Icon(
                      Icons.person,
                      size: 32.sp,
                      color: AppColors.backgroundWhite,
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            // Tên và email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontSize: 18.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  if (userEmail.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      userEmail,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
