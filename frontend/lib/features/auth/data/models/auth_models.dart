class RegisterRequestDto {
  const RegisterRequestDto({
    required this.email,
    required this.password,
    required this.pin,
    required this.language,
  });

  final String email;
  final String password;
  final String pin;
  final String language;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'pin': pin,
        'language': language,
      };
}

class LoginRequestDto {
  const LoginRequestDto({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class VerifyPinRequestDto {
  const VerifyPinRequestDto({required this.pin});

  final String pin;

  Map<String, dynamic> toJson() => {'pin': pin};
}

class ParentDto {
  const ParentDto({
    required this.id,
    this.email,
    this.language,
  });

  final String id;
  final String? email;
  final String? language;

  factory ParentDto.fromJson(Map<String, dynamic> json) {
    return ParentDto(
      id: (json['id'] ?? '').toString(),
      email: json['email'] as String?,
      language: json['language'] as String?,
    );
  }
}

class AuthResponseDto {
  const AuthResponseDto({
    this.token,
    required this.expiresInSeconds,
    this.parent,
  });

  final String? token;
  final int expiresInSeconds;
  final ParentDto? parent;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    final parentJson = json['parent'];
    return AuthResponseDto(
      token: json['token'] as String?,
      expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt() ?? 0,
      parent: parentJson is Map<String, dynamic>
          ? ParentDto.fromJson(parentJson)
          : (parentJson is Map
              ? ParentDto.fromJson(Map<String, dynamic>.from(parentJson))
              : null),
    );
  }
}

class VerifyPinResponseDto {
  const VerifyPinResponseDto({
    this.token,
    required this.expiresInSeconds,
  });

  final String? token;
  final int expiresInSeconds;

  factory VerifyPinResponseDto.fromJson(Map<String, dynamic> json) {
    return VerifyPinResponseDto(
      token: json['token'] as String?,
      expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt() ?? 0,
    );
  }
}
