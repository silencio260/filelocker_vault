import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/lockout_state_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthFirstTime extends AuthState {
  const AuthFirstTime();
}

class AuthUnlockRequired extends AuthState {
  final AuthEntity auth;
  final LockoutStateEntity lockout;
  const AuthUnlockRequired({required this.auth, required this.lockout});
  @override
  List<Object?> get props => [auth, lockout];
}

class AuthSuccess extends AuthState {
  const AuthSuccess();
}

class AuthPinSetupStep2 extends AuthState {
  final String firstPin;
  const AuthPinSetupStep2(this.firstPin);
  @override
  List<Object?> get props => [firstPin];
}

class AuthPinMismatch extends AuthState {
  const AuthPinMismatch();
}

class AuthFailure extends AuthState {
  final String message;
  final LockoutStateEntity lockout;
  const AuthFailure({required this.message, required this.lockout});
  @override
  List<Object?> get props => [message, lockout];
}

class AuthLockedOut extends AuthState {
  final LockoutStateEntity lockout;
  const AuthLockedOut(this.lockout);
  @override
  List<Object?> get props => [lockout];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthBiometricEnabled extends AuthState {
  const AuthBiometricEnabled();
}
