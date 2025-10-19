import 'package:flutter/material.dart';

/// Extension methods cho String để xử lý text dễ dàng hơn
extension StringExtensions on String {
  // ===== VALIDATION =====
  /// Kiểm tra string có rỗng không (bao gồm whitespace)
  bool get isEmptyOrNull => trim().isEmpty;
  
  /// Kiểm tra string có hợp lệ không
  bool get isNotEmptyOrNull => !isEmptyOrNull;
  
  /// Kiểm tra email hợp lệ
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
  
  /// Kiểm tra số điện thoại Việt Nam hợp lệ
  bool get isValidVietnamesePhone {
    return RegExp(r'^(\+84|84|0)(3|5|7|8|9)([0-9]{8})$').hasMatch(this);
  }
  
  /// Kiểm tra mật khẩu mạnh (ít nhất 8 ký tự, có chữ hoa, chữ thường, số)
  bool get isStrongPassword {
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$').hasMatch(this);
  }

  // ===== FORMATTING =====
  /// Viết hoa chữ cái đầu
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
  
  /// Viết hoa chữ cái đầu mỗi từ
  String get capitalizeWords {
    return split(' ').map((word) => word.capitalize).join(' ');
  }
  
  /// Loại bỏ dấu tiếng Việt
  String get removeVietnameseDiacritics {
    const vietnamese = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const english = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    
    String result = toLowerCase();
    for (int i = 0; i < vietnamese.length; i++) {
      result = result.replaceAll(vietnamese[i], english[i]);
    }
    return result;
  }
  
  /// Chuyển thành slug (URL friendly)
  String get toSlug {
    return removeVietnameseDiacritics
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
  
  /// Rút gọn text với ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }
  
  /// Định dạng số tiền VND
  String get formatCurrency {
    if (isEmpty) return '0 ₫';
    try {
      final number = int.parse(replaceAll(RegExp(r'[^0-9]'), ''));
      return '${number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )} ₫';
    } catch (e) {
      return this;
    }
  }
  
  /// Định dạng số điện thoại
  String get formatPhoneNumber {
    if (length == 10 && startsWith('0')) {
      return '${substring(0, 4)} ${substring(4, 7)} ${substring(7)}';
    } else if (length == 11 && startsWith('84')) {
      return '+84 ${substring(2, 5)} ${substring(5, 8)} ${substring(8)}';
    }
    return this;
  }

  // ===== UTILITIES =====
  /// Chuyển thành Color từ hex string
  Color get toColor {
    String hexColor = replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
  
  /// Tạo initials từ tên (VD: "Nguyễn Văn A" -> "NVA")
  String get initials {
    return split(' ')
        .where((word) => word.isNotEmpty)
        .take(3)
        .map((word) => word[0].toUpperCase())
        .join();
  }
  
  /// Kiểm tra có chứa từ khóa không (không phân biệt hoa thường, dấu)
  bool containsIgnoreCase(String keyword) {
    return removeVietnameseDiacritics.contains(
      keyword.removeVietnameseDiacritics,
    );
  }
  
  /// Highlight từ khóa trong text
  List<TextSpan> highlightKeyword(
    String keyword, {
    TextStyle? normalStyle,
    TextStyle? highlightStyle,
  }) {
    if (keyword.isEmpty) {
      return [TextSpan(text: this, style: normalStyle)];
    }
    
    final spans = <TextSpan>[];
    final lowerText = toLowerCase();
    final lowerKeyword = keyword.toLowerCase();
    
    int start = 0;
    int index = lowerText.indexOf(lowerKeyword);
    
    while (index != -1) {
      // Add text before keyword
      if (index > start) {
        spans.add(TextSpan(
          text: substring(start, index),
          style: normalStyle,
        ));
      }
      
      // Add highlighted keyword
      spans.add(TextSpan(
        text: substring(index, index + keyword.length),
        style: highlightStyle,
      ));
      
      start = index + keyword.length;
      index = lowerText.indexOf(lowerKeyword, start);
    }
    
    // Add remaining text
    if (start < length) {
      spans.add(TextSpan(
        text: substring(start),
        style: normalStyle,
      ));
    }
    
    return spans;
  }

  // ===== FILE & URL =====
  /// Lấy extension của file
  String get fileExtension {
    return split('.').last.toLowerCase();
  }
  
  /// Kiểm tra có phải file ảnh không
  bool get isImageFile {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(fileExtension);
  }
  
  /// Kiểm tra có phải URL hợp lệ không
  bool get isValidUrl {
    return Uri.tryParse(this)?.hasAbsolutePath ?? false;
  }
  
  /// Tạo asset path
  String get asAssetPath => 'assets/$this';
  
  /// Tạo image asset path
  String get asImageAsset => 'assets/images/$this';
  
  /// Tạo icon asset path
  String get asIconAsset => 'assets/icons/$this';
}
