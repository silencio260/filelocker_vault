import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String authMethod; // 'pin' | 'none'
  final bool biometricEnabled;
  final bool isFirstTime;
  final int failedAttempts;
  final DateTime? lockoutUntil;

  const AuthEntity({
    required this.authMethod,
    required this.biometricEnabled,
    required this.isFirstTime,
    required this.failedAttempts,
    this.lockoutUntil,
  });

  @override
  List<Object?> get props =>
      [authMethod, biometricEnabled, isFirstTime, failedAttempts, lockoutUntil];
}
