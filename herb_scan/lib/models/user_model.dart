/// Model cho User trong ứng dụng Herb Scan
class UserModel {
  /// ID của user (Firebase UID)
  final String id;
  
  /// Email của user
  final String email;
  
  /// Tên hiển thị
  final String displayName;
  
  /// URL avatar
  final String? photoURL;
  
  /// Số điện thoại
  final String? phoneNumber;
  
  /// Ngày tạo tài khoản
  final DateTime createdAt;
  
  /// Lần cập nhật cuối
  final DateTime updatedAt;
  
  /// Trạng thái email đã verify chưa
  final bool emailVerified;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
    this.emailVerified = false,
  });

  /// Copy constructor
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? emailVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  /// Chuyển đổi sang Map để lưu Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'emailVerified': emailVerified,
    };
  }

  /// Tạo instance từ Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoURL: map['photoURL'],
      phoneNumber: map['phoneNumber'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      emailVerified: map['emailVerified'] ?? false,
    );
  }

  /// Tạo từ Firebase User
  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    final now = DateTime.now();
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? '',
      photoURL: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      createdAt: firebaseUser.metadata.creationTime ?? now,
      updatedAt: now,
      emailVerified: firebaseUser.emailVerified,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Extension methods cho UserModel
extension UserModelExtension on UserModel {
  /// Lấy initials từ displayName
  String get initials {
    if (displayName.isEmpty) return 'U';
    final words = displayName.split(' ');
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }

  /// Kiểm tra profile có đầy đủ không
  bool get isProfileComplete {
    return displayName.isNotEmpty && email.isNotEmpty;
  }

  /// Lấy tên hiển thị ngắn gọn
  String get shortName {
    if (displayName.isEmpty) return email.split('@')[0];
    final words = displayName.split(' ');
    return words.length > 1 ? words[0] : displayName;
  }
}
