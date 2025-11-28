import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'constants/index.dart';
import 'widgets/auth_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // App Check: debug dùng Debug provider, release dùng Play Integrity
  await FirebaseAppCheck.instance.activate(
    androidProvider: kReleaseMode
        ? AndroidProvider.playIntegrity
        : AndroidProvider.debug,
  );
  
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
    return ScreenUtilInit(
      designSize: const Size(430, 932), // Design size từ Figma
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Herb Scan',
          theme: AppTheme.lightTheme.copyWith(
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          // Dark theme disabled - chỉ dùng light theme
          themeMode: ThemeMode.light,
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,
          builder: (context, widget) {
            // Đảm bảo text scale không vượt quá 1.3
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3),
              ),
              child: widget!,
            );
          },
        );
      },
    );
  }
}
