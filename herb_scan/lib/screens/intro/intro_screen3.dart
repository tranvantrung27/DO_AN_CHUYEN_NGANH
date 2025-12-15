import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/intro_navigation.dart';
import 'intro_screen2.dart';
import '../home/home_screen.dart';

class Intro3Screen extends StatelessWidget {
  const Intro3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: Container(
        width: 430,
        height: 932,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: AppColors.backgroundCream),
        child: Stack(
          children: [
            // Phần hình ảnh phía trên
            Positioned(
              left: 0,
              top: 0,
              child: SizedBox(
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
                            image: AssetImage('assets/images/images_intro/intro3.png'),
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
                          'Lưu trữ và tra cứu nhanh',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            height: 1.50,
                            letterSpacing: 0.12,
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: 318,
                          child: Text(
                            'Lưu lại lịch sử tìm kiếm và tạo bộ sưu tập cây thuốc yêu thích để tra cứu nhanh chóng.',
                            style: TextStyle(
                              color: const Color(0xFF4E4B66),
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                              letterSpacing: 0.12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Phần điều hướng và nút
            Positioned(
              left: 0,
              top: 802,
              child: IntroNavigation(
                currentIndex: 2,
                nextButtonText: 'Bắt đầu',
                onBack: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Intro2Screen()),
                  );
                },
                onNext: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
