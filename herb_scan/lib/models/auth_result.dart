/// Model cho kết quả authentication
class AuthResult {
  /// Trạng thái thành công
  final bool isSuccess;
  
  /// User data (nếu thành công)
  final dynamic user;
  
  /// Thông báo lỗi (nếu thất bại)
  final String? errorMessage;
  
  /// Mã lỗi
  final String? errorCode;
  
  /// Verification ID cho phone auth
  final String? verificationId;

  const AuthResult({
    required this.isSuccess,
    this.user,
    this.errorMessage,
    this.errorCode,
    this.verificationId,
  });

  /// Factory cho kết quả thành công
  factory AuthResult.success(dynamic user, {String? verificationId}) {
    return AuthResult(
      isSuccess: true,
      user: user,
      verificationId: verificationId,
    );
  }

  /// Factory cho kết quả thất bại
  factory AuthResult.failure({
    required String message,
    String? code,
  }) {
    return AuthResult(
      isSuccess: false,
      errorMessage: message,
      errorCode: code,
    );
  }

  @override
  String toString() {
    return 'AuthResult(isSuccess: $isSuccess, errorMessage: $errorMessage)';
  }
}

/// Enum cho các loại authentication
enum AuthType {
  login,
  register,
  googleSignIn,
  logout,
  resetPassword,
}

/// Model cho request đăng nhập
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
    };
  }
}

/// Model cho request đăng ký
class RegisterRequest {
  final String email;
  final String password;
  final String displayName;
  final String? phoneNumber;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.displayName,
    this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
    };
  }
}
