import 'package:intl/intl.dart';

/// Parser ngày "bắt mọi kiểu" - xử lý timestamp, ISO string, RSS format, VN format
DateTime? parsePublishedToUtc(dynamic v) {
  if (v == null) return null;

  // Xử lý timestamp (Unix timestamp)
  if (v is num || RegExp(r'^\d+$').hasMatch(v.toString().trim())) {
    final n = v is num ? v.toInt() : int.parse(v.toString().trim());
    final ms = n > 100000000000 ? n : n * 1000; // Xử lý cả second và millisecond
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toUtc();
  }

  final s = v.toString().trim();
  if (s.isEmpty) return null;

  // Thử parse ISO string trực tiếp
  try { 
    return DateTime.parse(s).toUtc(); 
  } catch (_) {}

  // Xử lý RSS format: "Wed, 02 Oct 2002 13:00:00 GMT"
  final norm = s.replaceFirst(RegExp(r'([+\-]\d{2}):(\d{2})$'), r'\1\2');
  try {
    final fmt = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US');
    return fmt.parse(norm, true).toUtc();
  } catch (_) {}

  // Xử lý format VN: "Chủ nhật, 19/10/2025, 13:00 ..."
  final m = RegExp(r'(?:(?:Thứ|Chủ)[^,]*,\s*)?(\d{1,2})\/(\d{1,2})\/(\d{4}).*?(\d{1,2}):(\d{2})').firstMatch(s);
  if (m != null) {
    final d  = int.parse(m.group(1)!);
    final mo = int.parse(m.group(2)!);
    final y  = int.parse(m.group(3)!);
    final h  = int.parse(m.group(4)!);
    final mi = int.parse(m.group(5)!);
    return DateTime(y, mo, d, h, mi).toUtc();
  }

  // Thử các format khác
  final formats = [
    'yyyy-MM-dd HH:mm:ss',
    'yyyy-MM-dd',
    'dd/MM/yyyy HH:mm:ss',
    'dd/MM/yyyy',
    'MM/dd/yyyy HH:mm:ss',
    'MM/dd/yyyy',
  ];

  for (final format in formats) {
    try {
      final fmt = DateFormat(format);
      return fmt.parse(s, true).toUtc();
    } catch (_) {}
  }

  return null;
}

/// Hiển thị thời gian tương đối bằng tiếng Việt
String relativeVi(DateTime dtUtc) {
  final dt = dtUtc.toLocal();
  final now = DateTime.now();
  final diff = now.difference(dt);
  
  if (diff.inSeconds < 30) return 'Vừa xong';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
  if (diff.inHours < 24) return '${diff.inHours} giờ trước';
  if (diff.inDays < 7) return '${diff.inDays} ngày trước';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} tuần trước';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} tháng trước';
  
  return DateFormat('dd/MM/yyyy').format(dt);
}

/// Format ngày cho hiển thị
String formatDateForDisplay(DateTime? date) {
  if (date == null) return 'Đang cập nhật';
  return relativeVi(date);
}
