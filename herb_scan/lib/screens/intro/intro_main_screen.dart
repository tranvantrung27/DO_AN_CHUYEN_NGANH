import 'package:flutter/material.dart';
import '../../constants/index.dart';
import '../../models/intro_content.dart';
import '../../widgets/index.dart';
import '../login/login_screen.dart';

class IntroMainScreen extends StatefulWidget {
  const IntroMainScreen({super.key});

  @override
  State<IntroMainScreen> createState() => _IntroMainScreenState();
}

class _IntroMainScreenState extends State<IntroMainScreen> {
  int currentIndex = 0;

  // Danh sách nội dung cho từng màn hình intro
  final List<IntroContent> introContents = [
    IntroContent(
      imagePath: 'assets/images/images_intro/intro1.png',
      title: 'Quét lá, biết ngay cây thuốc',
      description: 'Chỉ cần chụp một chiếc lá, AI sẽ phân tích và cho bạn biết đó là loại cây gì trong tích tắc.',
    ),
    IntroContent(
      imagePath: 'assets/images/images_intro/intro2.png',
      title: 'Thông tin chi tiết và chính xác',
      description: 'Nhận được thông tin đầy đủ về tên cây, công dụng, cách sử dụng và lưu ý khi dùng cây thuốc.',
    ),
    IntroContent(
      imagePath: 'assets/images/images_intro/intro3.png',
      title: 'Lưu trữ và tra cứu nhanh',
      description: 'Lưu lại lịch sử tìm kiếm và tạo bộ sưu tập cây thuốc yêu thích để tra cứu nhanh chóng.',
    ),
  ];

  void _nextScreen() {
    if (currentIndex < 2) {
      setState(() {
        currentIndex++;
      });
    } else {
      // Chuyển sang LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _previousScreen() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  String get nextButtonText {
    return currentIndex == 2 ? 'Bắt đầu' : 'Tiếp tục';
  }

  @override
  Widget build(BuildContext context) {
    final content = introContents[currentIndex];
    
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: Container(
        width: 430,
        height: 932,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: AppColors.backgroundCream),
        child: Stack(
          children: [
            // Phần content có thể thay đổi
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(currentIndex),
                child: Stack(
                  children: [
                    // Phần hình ảnh phía trên
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 430,
                        height: 588,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              child: Container(
                                width: 430,
                                height: 588,
                                decoration: BoxDecoration(color: const Color(0xFFC4C4C4)),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: -96.39,
                              child: Container(
                                width: 430,
                                height: 784,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(content.imagePath),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Phần nội dung phía dưới
                    Positioned(
                      left: 0,
                      top: 588,
                      child: Container(
                        width: 430,
                        height: 213,
                        padding: const EdgeInsets.only(
                          top: 24,
                          left: 24,
                          right: 24,
                          bottom: 8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  content.title,
                                  style: AppTheme.headingMedium,
                                ),
                                SizedBox(height: 10),
                                SizedBox(
                                  width: 318,
                                  child: Text(
                                    content.description,
                                    style: AppTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Phần navigation cố định ở dưới
            Positioned(
              left: 0,
              top: 802,
              child: IntroNavigation(
                currentIndex: currentIndex,
                nextButtonText: nextButtonText,
                onBack: currentIndex > 0 ? _previousScreen : null,
                onNext: _nextScreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

