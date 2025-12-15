import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../widgets/settings/index.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _newArticles = true;
  bool _reminders = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
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
          'Cài đặt thông báo',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsCard(
                children: [
                  SettingItemWithSwitch(
                    icon: Icons.notifications_active_outlined,
                    title: 'Thông báo đẩy',
                    value: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _pushNotifications = value;
                      });
                    },
                  ),
                  SettingItemWithSwitch(
                    icon: Icons.email_outlined,
                    title: 'Thông báo qua email',
                    value: _emailNotifications,
                    onChanged: (value) {
                      setState(() {
                        _emailNotifications = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              SettingsCard(
                children: [
                  SettingItemWithSwitch(
                    icon: Icons.article_outlined,
                    title: 'Bài viết mới',
                    value: _newArticles,
                    onChanged: (value) {
                      setState(() {
                        _newArticles = value;
                      });
                    },
                  ),
                  SettingItemWithSwitch(
                    icon: Icons.alarm_outlined,
                    title: 'Nhắc nhở',
                    value: _reminders,
                    onChanged: (value) {
                      setState(() {
                        _reminders = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

