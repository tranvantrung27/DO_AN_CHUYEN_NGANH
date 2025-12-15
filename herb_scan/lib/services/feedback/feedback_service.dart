import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Lưu feedback vào Firestore và upload ảnh lên Storage
  Future<Map<String, dynamic>> submitFeedback({
    required String content,
    List<File>? images,
  }) async {
    try {
      // Lấy thông tin user
      final user = _auth.currentUser;
      String? userId = user?.uid;
      
      if (userId == null) {
        final prefs = await SharedPreferences.getInstance();
        userId = prefs.getString('current_user_id');
      }

      // Upload ảnh lên Firebase Storage và lấy URLs
      List<String> imageUrls = [];
      if (images != null && images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          try {
            // Kiểm tra file tồn tại
            if (!await images[i].exists()) {
              print('File không tồn tại: ${images[i].path}');
              continue;
            }

            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final fileName = 'feedback_${userId ?? 'anonymous'}_${timestamp}_$i.jpg';
            final storageRef = _storage
                .ref()
                .child('feedback_images')
                .child(fileName);

            print('Đang upload ảnh $i: $fileName');

            final uploadTask = storageRef.putFile(
              images[i],
              SettableMetadata(
                contentType: 'image/jpeg',
                cacheControl: 'public, max-age=31536000',
              ),
            );

            final snapshot = await uploadTask;
            print('Upload state: ${snapshot.state}');
            
            if (snapshot.state == TaskState.success) {
              final downloadURL = await snapshot.ref.getDownloadURL();
              print('Upload thành công, URL: $downloadURL');
              imageUrls.add(downloadURL);
            } else {
              print('Upload không thành công, state: ${snapshot.state}');
            }
          } catch (e, stackTrace) {
            print('Lỗi khi upload ảnh $i: $e');
            print('StackTrace: $stackTrace');
            // Tiếp tục với các ảnh khác
          }
        }
      }
      
      print('Tổng số ảnh đã upload: ${imageUrls.length}');

      // Lưu feedback vào Firestore
      final feedbackData = {
        'content': content,
        'imageUrls': imageUrls,
        'userId': userId ?? 'anonymous',
        'userEmail': user?.email,
        'userDisplayName': user?.displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, read, replied, resolved
        'replyMessage': null,
        'repliedAt': null,
      };

      final docRef = await _firestore.collection('feedback').add(feedbackData);

      return {
        'success': true,
        'feedbackId': docRef.id,
        'message': 'Đã gửi phản hồi thành công!',
      };
    } catch (e) {
      print('Lỗi khi gửi feedback: $e');
      return {
        'success': false,
        'message': 'Lỗi khi gửi phản hồi: ${e.toString()}',
      };
    }
  }

  /// Lấy userId hiện tại (từ Auth hoặc SharedPreferences)
  Future<String?> _getCurrentUserId() async {
    // Ưu tiên lấy từ Firebase Auth
    final user = _auth.currentUser;
    if (user != null && user.uid.isNotEmpty) {
      return user.uid;
    }
    
    // Nếu không có, thử lấy từ SharedPreferences (cho phone login)
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');
      if (userId != null && userId.isNotEmpty) {
        return userId;
      }
    } catch (e) {
      print('Lỗi khi lấy userId từ SharedPreferences: $e');
    }
    
    return null;
  }

  /// Lấy danh sách feedback của user hiện tại
  /// Mỗi user chỉ thấy feedback của chính mình
  Stream<List<Map<String, dynamic>>> getUserFeedback() {
    return Stream.fromFuture(_getCurrentUserId()).asyncExpand((userId) {
      // Nếu không có userId, trả về stream rỗng
      if (userId == null || userId.isEmpty) {
        return Stream.value(<Map<String, dynamic>>[]);
      }

      // Lấy feedback của user này
      return _firestore
          .collection('feedback')
          .where('userId', isEqualTo: userId) // Chỉ lấy feedback của user này
          .snapshots()
          .map((snapshot) {
        final feedbackList = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
            'createdAt': data['createdAt']?.toDate(),
            'repliedAt': data['repliedAt']?.toDate(),
          };
        }).toList();
        
        // Sort ở client side theo createdAt (mới nhất trước)
        feedbackList.sort((a, b) {
          final aDate = a['createdAt'] as DateTime?;
          final bDate = b['createdAt'] as DateTime?;
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate); // Descending
        });
        
        return feedbackList;
      });
    });
  }

  /// Lấy feedback của user (async, không stream)
  /// Mỗi user chỉ thấy feedback của chính mình
  Future<List<Map<String, dynamic>>> getUserFeedbackList() async {
    try {
      // Lấy userId hiện tại
      final userId = await _getCurrentUserId();
      
      if (userId == null || userId.isEmpty) {
        return [];
      }

      // Lấy feedback của user này
      final snapshot = await _firestore
          .collection('feedback')
          .where('userId', isEqualTo: userId) // Chỉ lấy feedback của user này
          .get();

      final feedbackList = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'createdAt': data['createdAt']?.toDate(),
          'repliedAt': data['repliedAt']?.toDate(),
        };
      }).toList();
      
      // Sort ở client side theo createdAt (mới nhất trước)
      feedbackList.sort((a, b) {
        final aDate = a['createdAt'] as DateTime?;
        final bDate = b['createdAt'] as DateTime?;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate); // Descending
      });
      
      return feedbackList;
    } catch (e) {
      print('Lỗi khi lấy feedback: $e');
      return [];
    }
  }
}

