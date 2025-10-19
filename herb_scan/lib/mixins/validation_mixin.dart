import 'package:flutter/material.dart';
import '../extensions/string_extensions.dart';

/// Mixin để validation forms
mixin ValidationMixin<T extends StatefulWidget> on State<T> {
  final Map<String, String?> _errors = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  /// Getter cho errors
  Map<String, String?> get errors => _errors;
  
  /// Getter cho controllers
  Map<String, TextEditingController> get controllers => _controllers;
  
  /// Getter cho focus nodes
  Map<String, FocusNode> get focusNodes => _focusNodes;

  @override
  void dispose() {
    // Dispose tất cả controllers và focus nodes
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  /// Tạo hoặc lấy TextEditingController
  TextEditingController getController(String key, {String? initialValue}) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: initialValue);
    }
    return _controllers[key]!;
  }

  /// Tạo hoặc lấy FocusNode
  FocusNode getFocusNode(String key) {
    if (!_focusNodes.containsKey(key)) {
      _focusNodes[key] = FocusNode();
    }
    return _focusNodes[key]!;
  }

  /// Validate một field
  bool validateField(
    String key,
    String? value, {
    bool required = true,
    int? minLength,
    int? maxLength,
    String? pattern,
    String? Function(String?)? customValidator,
  }) {
    String? error;

    // Required validation
    if (required && (value == null || value.trim().isEmpty)) {
      error = 'Trường này là bắt buộc';
    }
    // Min length validation
    else if (minLength != null && value != null && value.length < minLength) {
      error = 'Tối thiểu $minLength ký tự';
    }
    // Max length validation
    else if (maxLength != null && value != null && value.length > maxLength) {
      error = 'Tối đa $maxLength ký tự';
    }
    // Pattern validation
    else if (pattern != null && value != null && !RegExp(pattern).hasMatch(value)) {
      error = 'Định dạng không hợp lệ';
    }
    // Custom validation
    else if (customValidator != null) {
      error = customValidator(value);
    }

    _errors[key] = error;
    if (mounted) setState(() {});
    
    return error == null;
  }

  /// Validate email field
  bool validateEmail(String key, String? value, {bool required = true}) {
    return validateField(
      key,
      value,
      required: required,
      customValidator: (value) {
        if (value != null && value.isNotEmpty && !value.isValidEmail) {
          return 'Email không hợp lệ';
        }
        return null;
      },
    );
  }

  /// Validate password field
  bool validatePassword(String key, String? value, {bool required = true, bool strong = false}) {
    return validateField(
      key,
      value,
      required: required,
      minLength: strong ? 8 : 6,
      customValidator: strong ? (value) {
        if (value != null && value.isNotEmpty && !value.isStrongPassword) {
          return 'Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường và số';
        }
        return null;
      } : null,
    );
  }

  /// Validate phone number field
  bool validatePhone(String key, String? value, {bool required = true}) {
    return validateField(
      key,
      value,
      required: required,
      customValidator: (value) {
        if (value != null && value.isNotEmpty && !value.isValidVietnamesePhone) {
          return 'Số điện thoại không hợp lệ';
        }
        return null;
      },
    );
  }

  /// Validate confirm password
  bool validateConfirmPassword(String key, String? value, String? originalPassword) {
    return validateField(
      key,
      value,
      required: true,
      customValidator: (value) {
        if (value != originalPassword) {
          return 'Mật khẩu xác nhận không khớp';
        }
        return null;
      },
    );
  }

  /// Validate tất cả fields
  bool validateAllFields() {
    bool isValid = true;
    for (final entry in _controllers.entries) {
      final key = entry.key;
      final controller = entry.value;
      
      // Gọi validation tương ứng với từng field
      // Có thể override method này trong class con để define validation rules
      if (!validateField(key, controller.text)) {
        isValid = false;
      }
    }
    return isValid;
  }

  /// Clear tất cả errors
  void clearErrors() {
    _errors.clear();
    if (mounted) setState(() {});
  }

  /// Clear error của một field cụ thể
  void clearError(String key) {
    _errors.remove(key);
    if (mounted) setState(() {});
  }

  /// Lấy error message của một field
  String? getError(String key) => _errors[key];

  /// Kiểm tra field có error không
  bool hasError(String key) => _errors[key] != null;

  /// Focus vào field đầu tiên có error
  void focusFirstError() {
    for (final key in _errors.keys) {
      if (_errors[key] != null && _focusNodes.containsKey(key)) {
        _focusNodes[key]!.requestFocus();
        break;
      }
    }
  }

  /// Tạo InputDecoration với error message
  InputDecoration getInputDecoration({
    required String key,
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorText: getError(key),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: hasError(key) ? Colors.red : Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: hasError(key) ? Colors.red : Theme.of(context).primaryColor,
          width: 2,
        ),
      ),
    );
  }
}
