import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'home/home_screen.dart';
import 'scan/scan_screen.dart';
import 'herballibrary/herballibrary_screen.dart';
import 'history/history_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final ValueNotifier<int> _tabChangeNotifier = ValueNotifier<int>(0);

  List<Widget> get _screens => [
    const HomeScreen(),           // 0: Trang chủ
    const HistoryScreen(),        // 1: Lịch sử
    const ScanScreen(),           // 2: Quét
    HerbLibraryScreen(            // 3: Kho thuốc
      tabChangeNotifier: _tabChangeNotifier,
    ),
    const SettingsScreen(),       // 4: Cài đặt
  ];

  @override
  void dispose() {
    _tabChangeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Notify tab change
          _tabChangeNotifier.value = index;
        },
      ),
    );
  }
}
