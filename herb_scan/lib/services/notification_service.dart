import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service để gửi thông báo qua Firebase Templates
class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Gửi thông báo đăng ký thành công
  static Future<void> sendRegistrationSuccessNotification({
    required String phoneNumber,
    required String displayName,
  }) async {
    try {
      // Lưu thông báo vào Firestore để có thể gửi qua Cloud Functions
      await _firestore.collection('notifications').add({
        'type': 'registration_success',
        'phoneNumber': phoneNumber,
        'displayName': displayName,
        'message': 'Chào mừng $displayName! Tài khoản Herb Scan của bạn đã được tạo thành công.',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'userId': _auth.currentUser?.uid,
      });
      
      print('✅ Registration success notification queued for $phoneNumber');
    } catch (e) {
      print('❌ Error sending registration notification: $e');
    }
  }

  /// Gửi thông báo OTP
  static Future<void> sendOTPNotification({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'type': 'otp_sent',
        'phoneNumber': phoneNumber,
        'message': 'Mã OTP của bạn là: $otpCode. Mã này có hiệu lực trong 5 phút.',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      
      print('✅ OTP notification queued for $phoneNumber');
    } catch (e) {
      print('❌ Error sending OTP notification: $e');
    }
  }

  /// Gửi thông báo đăng nhập thành công
  static Future<void> sendLoginSuccessNotification({
    required String phoneNumber,
    required String displayName,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'type': 'login_success',
        'phoneNumber': phoneNumber,
        'displayName': displayName,
        'message': 'Chào mừng trở lại $displayName! Bạn đã đăng nhập thành công vào Herb Scan.',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'userId': _auth.currentUser?.uid,
      });
      
      print('✅ Login success notification queued for $phoneNumber');
    } catch (e) {
      print('❌ Error sending login notification: $e');
    }
  }

  /// Gửi thông báo cảnh báo đăng nhập từ thiết bị mới
  static Future<void> sendNewDeviceLoginNotification({
    required String phoneNumber,
    required String displayName,
    required String deviceInfo,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'type': 'new_device_login',
        'phoneNumber': phoneNumber,
        'displayName': displayName,
        'deviceInfo': deviceInfo,
        'message': 'Cảnh báo: Tài khoản $displayName đã đăng nhập từ thiết bị mới ($deviceInfo).',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'userId': _auth.currentUser?.uid,
      });
      
      print('✅ New device login notification queued for $phoneNumber');
    } catch (e) {
      print('❌ Error sending new device notification: $e');
    }
  }

  /// Gửi thông báo khôi phục mật khẩu
  static Future<void> sendPasswordResetNotification({
    required String phoneNumber,
    required String displayName,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'type': 'password_reset',
        'phoneNumber': phoneNumber,
        'displayName': displayName,
        'message': 'Mật khẩu của bạn đã được đặt lại thành công. Nếu không phải bạn thực hiện, vui lòng liên hệ hỗ trợ.',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'userId': _auth.currentUser?.uid,
      });
      
      print('✅ Password reset notification queued for $phoneNumber');
    } catch (e) {
      print('❌ Error sending password reset notification: $e');
    }
  }

  /// Lấy danh sách thông báo của user
  static Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('❌ Error getting user notifications: $e');
      return [];
    }
  }

  /// Đánh dấu thông báo đã đọc
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'status': 'read',
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }
}
