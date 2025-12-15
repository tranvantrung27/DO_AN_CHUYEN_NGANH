import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter_tts/flutter_tts.dart';

/// Service xử lý Text-to-Speech
/// Hỗ trợ Android, iOS. Windows và Web sẽ bỏ qua (chỉ log).
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isSupported = false;

  /// Kiểm tra platform có hỗ trợ TTS không
  bool get isSupported => _isSupported;

  /// Khởi tạo TTS
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Chỉ hỗ trợ Android và iOS
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      _isSupported = false;
      _isInitialized = true;
      if (kDebugMode) {
        print('ℹ️ TTS không được hỗ trợ trên platform này');
      }
      return;
    }

    // Chỉ sử dụng flutter_tts trên Android/iOS
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        _flutterTts = FlutterTts();
        await _flutterTts!.setLanguage("vi-VN");
        await _flutterTts!.setSpeechRate(0.5);
        await _flutterTts!.setVolume(1.0);
        await _flutterTts!.setPitch(1.0);
        _isSupported = true;
      } catch (e) {
        if (kDebugMode) {
          print('❌ TTS Initialize Error: $e');
        }
        _isSupported = false;
      }
    }

    _isInitialized = true;
  }

  /// Phát âm thanh
  Future<void> speak(String text) async {
    if (!_isSupported) {
      // Trên Windows/Web, chỉ print ra console
      if (kDebugMode) {
        print('🔊 TTS (not supported on this platform): $text');
      }
      return;
    }

    try {
      if (!_isInitialized) {
        await initialize();
      }
      if (_isSupported && _flutterTts != null) {
        await _flutterTts!.speak(text);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ TTS Error: $e');
      }
    }
  }

  /// Dừng phát âm thanh
  Future<void> stop() async {
    if (!_isSupported) return;

    try {
      if (_flutterTts != null) {
        await _flutterTts!.stop();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ TTS Stop Error: $e');
      }
    }
  }

  /// Tạo câu nói từ tên lá và các công dụng
  String generateSpeechText(String herbName, List<String> benefits) {
    if (benefits.isEmpty) {
      return 'Đã nhận diện $herbName. Bạn muốn tìm hiểu thêm về cây này không?';
    }

    // Lấy 3 công dụng đầu tiên
    final mainBenefits = benefits.take(3).toList();
    String benefitsText = '';

    if (mainBenefits.length == 1) {
      benefitsText = mainBenefits[0].toLowerCase();
    } else if (mainBenefits.length == 2) {
      benefitsText = '${mainBenefits[0].toLowerCase()} hoặc ${mainBenefits[1].toLowerCase()}';
    } else {
      benefitsText = '${mainBenefits[0].toLowerCase()}, ${mainBenefits[1].toLowerCase()} hoặc ${mainBenefits[2].toLowerCase()}';
    }

    return 'Đã nhận diện $herbName. Cây này thường dùng trị $benefitsText. Bạn muốn tìm hiểu kỹ về vấn đề nào?';
  }
}
