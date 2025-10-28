class LoginResponseDto {
  final bool success;
  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final String? user;

  LoginResponseDto({
    required this.success,
    this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      success: json['success'] as bool,
      message: json['message'] as String?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user,
    };
  }
}
