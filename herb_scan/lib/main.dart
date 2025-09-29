import 'package:flutter/material.dart';
import 'screens/intro/intro_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    // Khởi tạo các service nặng sau frame đầu
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Firebase, SharedPreferences, model loading... ở đây
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Herb Scan',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      home: const IntroScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
