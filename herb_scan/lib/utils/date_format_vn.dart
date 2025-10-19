import 'package:intl/intl.dart';

String formatVietnameseDateFromRss(String? rssPubDate) {
  if (rssPubDate == null || rssPubDate.trim().isEmpty) return '';
  DateTime? dt;
  try {
    // Example: Sun, 19 Oct 2025 17:30:00 +0700
    dt = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US').parse(rssPubDate, true).toLocal();
  } catch (_) {
    try {
      dt = DateTime.parse(rssPubDate).toLocal();
    } catch (_) {
      return rssPubDate;
    }
  }
  return formatVietnameseDate(dt);
}

String formatVietnameseDate(DateTime dt) {
  const weekdays = {
    1: 'Thứ hai',
    2: 'Thứ ba',
    3: 'Thứ tư',
    4: 'Thứ năm',
    5: 'Thứ sáu',
    6: 'Thứ bảy',
    7: 'Chủ nhật',
  };
  final weekday = weekdays[dt.weekday] ?? '';
  final date = DateFormat('dd/MM/yyyy').format(dt);
  final time = DateFormat('HH:mm').format(dt);
  final offsetHours = dt.timeZoneOffset.inHours;
  final gmt = 'GMT${offsetHours >= 0 ? '+' : ''}$offsetHours';
  return '$weekday, $date, $time ($gmt)';
}


