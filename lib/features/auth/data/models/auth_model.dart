import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  const AuthModel({
    required super.authMethod,
    required super.biometricEnabled,
    required super.isFirstTime,
    required super.failedAttempts,
    super.lockoutUntil,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      authMethod: json['authMethod'] as String? ?? 'none',
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      isFirstTime: json['isFirstTime'] as bool? ?? true,
      failedAttempts: json['failedAttempts'] as int? ?? 0,
      lockoutUntil: json['lockoutUntil'] != null
          ? DateTime.parse(json['lockoutUntil'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'authMethod': authMethod,
        'biometricEnabled': biometricEnabled,
        'isFirstTime': isFirstTime,
        'failedAttempts': failedAttempts,
        'lockoutUntil': lockoutUntil?.toIso8601String(),
      };
}
