import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Widget hiển thị thông tin người dùng (avatar + tên)
class UserProfileCard extends StatelessWidget {
  final User? user;

  const UserProfileCard({
    super.key,
    required this.user,
  });

  String _getUserName(User? user) {
    if (user == null) return 'Người dùng';
    
    // Lấy tên từ email (bỏ @gmail.com và phần sau)
    if (user.email != null) {
      return user.email!.split('@')[0];
    }
    
    // Nếu không có email, dùng displayName
    return user.displayName ?? 'Người dùng';
  }

  String? _getUserAvatarUrl(User? user) {
    return user?.photoURL;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userName = _getUserName(user);
    final avatarUrl = _getUserAvatarUrl(user);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      decoration: ShapeDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52.w,
            height: 52.w,
            decoration: ShapeDecoration(
              image: avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(avatarUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: avatarUrl == null 
                  ? (theme.brightness == Brightness.dark 
                      ? Colors.grey[700] 
                      : Colors.grey[300]) 
                  : null,
              shape: const OvalBorder(),
            ),
            child: avatarUrl == null
                ? Icon(
                    Icons.person,
                    size: 32.sp,
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  )
                : null,
          ),
          SizedBox(width: 12.w),
          // Tên người dùng
          Text(
            userName,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color ?? 
                    (theme.brightness == Brightness.dark 
                        ? Colors.white 
                        : const Color(0xFF333333)),
              fontSize: 17.sp,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              letterSpacing: -0.17,
            ),
          ),
        ],
      ),
    );
  }
}

