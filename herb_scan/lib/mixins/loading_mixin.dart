import 'package:flutter/material.dart';

/// Mixin để quản lý trạng thái loading
mixin LoadingMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;
  String? _loadingMessage;

  /// Getter cho trạng thái loading
  bool get isLoading => _isLoading;
  
  /// Getter cho loading message
  String? get loadingMessage => _loadingMessage;

  /// Bắt đầu loading
  void startLoading([String? message]) {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadingMessage = message;
      });
    }
  }

  /// Dừng loading
  void stopLoading() {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
      });
    }
  }

  /// Execute một function với loading state
  Future<R> withLoading<R>(
    Future<R> Function() function, {
    String? message,
  }) async {
    startLoading(message);
    try {
      final result = await function();
      return result;
    } finally {
      stopLoading();
    }
  }

  /// Execute một function với loading state và error handling
  Future<R?> withLoadingAndErrorHandling<R>(
    Future<R> Function() function, {
    String? loadingMessage,
    String? errorMessage,
    void Function(dynamic error)? onError,
  }) async {
    startLoading(loadingMessage);
    try {
      final result = await function();
      return result;
    } catch (error) {
      if (onError != null) {
        onError(error);
      } else {
        // Default error handling
        if (mounted) {
          // Ưu tiên thông báo từ Exception, sau đó mới dùng errorMessage
          String displayMessage;
          if (error is Exception) {
            displayMessage = error.toString().replaceFirst('Exception: ', '');
          } else {
            displayMessage = errorMessage ?? 'Đã xảy ra lỗi: $error';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(displayMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return null;
    } finally {
      stopLoading();
    }
  }
}
