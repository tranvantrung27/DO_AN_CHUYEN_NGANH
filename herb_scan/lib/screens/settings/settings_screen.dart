import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/index.dart';
import '../../widgets/settings/index.dart';
import '../../constants/app_colors.dart';
import 'details/index.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final SettingsLogoutHandler _logoutHandler = SettingsLogoutHandler();
  bool _isDarkMode = false;
  bool _isBiometricEnabled = false;

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
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thẻ Avatar + Tên người dùng + Email
              UserProfileCard(user: user),

              SizedBox(height: 20.h),

              // Nhóm 1: Personal và Saved Content
              SettingsCard(
                children: [
                  SettingItem(
                    icon: Icons.person_outline,
                    title: 'Thông tin cá nhân',
                    iconColor: AppColors.info,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PersonalInfoScreen(),
                        ),
                      );
                      // Reload lại để cập nhật UI khi quay lại
                      setState(() {});
                    },
                  ),
                  SettingItem(
                    icon: Icons.bookmark_outline,
                    title: 'Tin Đã lưu',
                    iconColor: AppColors.info,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SavedArticlesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Nhóm 2: App Settings
              SettingsCard(
                children: [
                  SettingItem(
                    icon: Icons.notifications_outlined,
                    title: 'Cài đặt thông báo',
                    iconColor: AppColors.info,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  SettingItemWithSwitch(
                    icon: Icons.brightness_6_outlined,
                    title: 'Giao diện sáng tối',
                    iconColor: AppColors.info,
                    value: _isDarkMode,
                    onChanged: _toggleDarkMode,
                  ),
                  SettingItem(
                    icon: Icons.language_outlined,
                    title: 'Ngôn ngữ',
                    iconColor: AppColors.info,
                    onTap: () {
                      // TODO: Implement language selection
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tính năng đang được phát triển'),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Nhóm 3: Security Settings
              SettingsCard(
                children: [
                  SettingItem(
                    icon: Icons.lock_outline,
                    title: 'Đổi mật khẩu',
                    iconColor: AppColors.warning,
                    onTap: () {
                      // TODO: Implement change password
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tính năng đang được phát triển'),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                  ),
                  SettingItemWithSwitch(
                    icon: Icons.fingerprint_outlined,
                    title: 'Đăng nhập sinh trắc học',
                    iconColor: AppColors.warning,
                    value: _isBiometricEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isBiometricEnabled = value;
                      });
                    },
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Nhóm 4: App Info
              SettingsCard(
                children: [
                  SettingItem(
                    icon: Icons.help_outline,
                    title: 'Cách sử dụng',
                    iconColor: AppColors.info,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UsageGuideScreen(),
                        ),
                      );
                    },
                  ),
                  SettingItem(
                    icon: Icons.feedback_outlined,
                    title: 'Gửi phản hồi',
                    iconColor: AppColors.info,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeedbackScreen(),
                        ),
                      );
                    },
                  ),
                  SettingItem(
                    icon: Icons.info_outline,
                    title: 'Thông tin giới thiệu',
                    iconColor: AppColors.info,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
                    },
                  ),
                  SettingItem(
                    icon: Icons.security_outlined,
                    title: 'Chính sách bảo mật',
                    iconColor: AppColors.info,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                  SettingItem(
                    icon: Icons.description_outlined,
                    title: 'Điều khoản & Điều kiện',
                    iconColor: AppColors.info,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsConditionsScreen(),
                        ),
                      );
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

              // Version
              Center(
                child: Text(
                  'Phiên bản 1.0.0',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
