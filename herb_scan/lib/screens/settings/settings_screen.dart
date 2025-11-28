import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/index.dart';
import '../../widgets/settings/index.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final SettingsLogoutHandler _logoutHandler = SettingsLogoutHandler();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
  }

  Future<void> _loadDarkModePreference() async {
    final isDarkMode = await DarkModeManager.loadDarkModePreference();
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() {
      _isDarkMode = value;
    });
    // Lưu preference nhưng không kích hoạt dark mode
    await DarkModeManager.saveDarkModePreference(value);
    // Note: Dark mode không được kích hoạt trong main.dart
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              
              // Thẻ Avatar + Tên người dùng
              UserProfileCard(user: user),

              SizedBox(height: 15.h),

              // Thẻ: Thông tin cá nhân, Tin Đã lưu
              SettingsCard(
                children: [
                  SettingItem(
                    icon: Icons.person_outline,
                    title: 'Thông tin cá nhân',
                    onTap: () {
                      // TODO: Navigate to personal info screen
                    },
                  ),
                  SettingItem(
                    icon: Icons.bookmark_outline,
                    title: 'Tin Đã lưu',
                    onTap: () {
                      // TODO: Navigate to saved articles screen
                    },
                  ),
                ],
              ),

              SizedBox(height: 15.h),

              // Thẻ: Cài đặt thông báo, Giao diện sáng tối
              SettingsCard(
                children: [
                  SettingItem(
                    icon: Icons.notifications_outlined,
                    title: 'Cài đặt thông báo',
                    onTap: () {
                      // TODO: Navigate to notification settings screen
                    },
                  ),
                  SettingItemWithSwitch(
                    icon: Icons.brightness_6_outlined,
                    title: 'Giao diện sáng tối',
                    value: _isDarkMode,
                    onChanged: _toggleDarkMode, // Switch hoạt động nhưng không kích hoạt dark mode
                  ),
                ],
              ),

              SizedBox(height: 15.h),

              // Thẻ: Cách sử dụng, Gửi phản hồi, Thông tin giới thiệu, Chính sách bảo mật, Điều khoản & Điều kiện
              SettingsCard(
                children: [
                  SettingItem(
                    icon: Icons.help_outline,
                    title: 'Cách sử dụng',
                    onTap: () {
                      // TODO: Navigate to usage guide screen
                    },
                  ),
                  SettingItem(
                    icon: Icons.feedback_outlined,
                    title: 'Gửi phản hồi',
                    onTap: () {
                      // TODO: Navigate to feedback screen
                    },
                  ),
                  SettingItem(
                    icon: Icons.info_outline,
                    title: 'Thông tin giới thiệu',
                    onTap: () {
                      // TODO: Navigate to about screen
                    },
                  ),
                  SettingItem(
                    icon: Icons.security_outlined,
                    title: 'Chính sách bảo mật',
                    onTap: () {
                      // TODO: Navigate to privacy policy screen
                    },
                  ),
                  SettingItem(
                    icon: Icons.description_outlined,
                    title: 'Điều khoản & Điều kiện',
                    onTap: () {
                      // TODO: Navigate to terms and conditions screen
                    },
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Nút Đăng xuất
              LogoutButton(
                onTap: () => _logoutHandler.handleLogout(context),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

}
