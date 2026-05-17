import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckFirstTimeEvent extends AuthEvent {
  const AuthCheckFirstTimeEvent();
}

class AuthSetupPinEvent extends AuthEvent {
  final String pin;
  const AuthSetupPinEvent(this.pin);
  @override
  List<Object?> get props => [pin];
}

class AuthConfirmPinEvent extends AuthEvent {
  final String pin;
  const AuthConfirmPinEvent(this.pin);
  @override
  List<Object?> get props => [pin];
}

class AuthVerifyPinEvent extends AuthEvent {
  final String pin;
  const AuthVerifyPinEvent(this.pin);
  @override
  List<Object?> get props => [pin];
}

class AuthBiometricEvent extends AuthEvent {
  const AuthBiometricEvent();
}

class AuthEnableBiometricEvent extends AuthEvent {
  const AuthEnableBiometricEvent();
}

class AuthRegisterFailedAttemptEvent extends AuthEvent {
  const AuthRegisterFailedAttemptEvent();
}

class AuthResetFailedAttemptsEvent extends AuthEvent {
  const AuthResetFailedAttemptsEvent();
}
