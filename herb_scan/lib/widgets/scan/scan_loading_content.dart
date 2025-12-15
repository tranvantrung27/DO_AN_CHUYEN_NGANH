import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

/// Widget hiển thị nội dung loading cho scan
class ScanLoadingContent extends StatefulWidget {
  final String title;
  final String? subtitle;

  const ScanLoadingContent({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  State<ScanLoadingContent> createState() => _ScanLoadingContentState();
}

class _ScanLoadingContentState extends State<ScanLoadingContent>
    with TickerProviderStateMixin {
  static const String _lottieAsset = 'assets/animated_plant_loader.json';
  late AnimationController _lottieController;
  late AnimationController _textController;
  Timer? _dotsTimer;
  String _displayedText = '';
  int _currentIndex = 0;
  bool _showDots = false;
  int _dotCount = 0;
  String _textWithoutDots = '';

  @override
  void initState() {
    super.initState();
    // Controller cho Lottie animation
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Chậm hơn
    );
    _lottieController.repeat();

    // Controller cho text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80), // Tốc độ đánh chữ (chậm hơn)
    );

    // Bắt đầu typewriter effect chỉ khi subtitle có "..."
    if (widget.subtitle != null && widget.subtitle!.contains('...')) {
      _startTypewriter();
    }
  }

  void _startTypewriter() {
    // Reset state
    _displayedText = '';
    _currentIndex = 0;
    _showDots = false;
    _dotCount = 0;
    _dotsTimer?.cancel();
    _textController.reset();

    final fullText = widget.subtitle!;
    _textWithoutDots = fullText.replaceAll('...', '');
    final hasDots = fullText.contains('...');

    // Thêm status listener
    _textController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_currentIndex < _textWithoutDots.length) {
          setState(() {
            _displayedText = _textWithoutDots.substring(0, _currentIndex + 1);
            _currentIndex++;
          });
          _textController.reset();
          _textController.forward();
        } else if (hasDots && !_showDots) {
          // Bắt đầu animate 3 chấm
          _showDots = true;
          _startDotsAnimation();
        }
      }
    });

    _textController.forward();
  }

  void _startDotsAnimation() {
    // Animate 3 chấm lặp lại liên tục (chậm hơn)
    _dotsTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4; // 0, 1, 2, 3 (0 = không chấm, 3 = 3 chấm)
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void didUpdateWidget(ScanLoadingContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset và bắt đầu lại nếu subtitle thay đổi
    if (oldWidget.subtitle != widget.subtitle) {
      _dotsTimer?.cancel();
      _textController.reset();
      // Chỉ bắt đầu typewriter nếu subtitle có "..."
      if (widget.subtitle != null && widget.subtitle!.contains('...')) {
        _startTypewriter();
      } else {
        // Reset state nếu không có typewriter
        _displayedText = '';
        _currentIndex = 0;
        _showDots = false;
        _dotCount = 0;
      }
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _textController.dispose();
    _dotsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Lottie animation
        SizedBox(
          width: 150.w,
          height: 150.w,
          child: Lottie.asset(
            _lottieAsset,
            controller: _lottieController,
            fit: BoxFit.contain,
            repeat: false, // Không repeat tự động vì đã dùng controller.repeat()
            options: LottieOptions(
              enableMergePaths: true,
            ),
            errorBuilder: (context, error, stackTrace) {
              // Log lỗi để debug
              debugPrint('Lottie error: $error');
              debugPrint('Stack trace: $stackTrace');
              // Fallback nếu lỗi load Lottie
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              );
            },
            frameRate: FrameRate.max,
          ),
        ),
        SizedBox(height: 32.h),
        // Title
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideY(begin: 0.2, end: 0),
        // Subtitle với typewriter effect (chỉ khi có "...")
        if (widget.subtitle != null) ...[
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              // Nếu có "..." thì dùng typewriter, nếu không thì hiển thị bình thường
              widget.subtitle!.contains('...')
                  ? (_displayedText.isEmpty && !_showDots
                      ? widget.subtitle!
                      : _displayedText + (_showDots ? '.' * _dotCount : ''))
                  : widget.subtitle!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
          ),
        ],
      ],
    );
  }
}

