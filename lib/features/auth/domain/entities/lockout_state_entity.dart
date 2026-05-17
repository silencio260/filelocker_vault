import 'package:equatable/equatable.dart';

class LockoutStateEntity extends Equatable {
  final bool isLockedOut;
  final Duration remainingLockout;
  final int attemptsRemaining;
  final bool protectionEnabled;

  const LockoutStateEntity({
    required this.isLockedOut,
    required this.remainingLockout,
    required this.attemptsRemaining,
    required this.protectionEnabled,
  });

  @override
  List<Object?> get props =>
      [isLockedOut, remainingLockout, attemptsRemaining, protectionEnabled];
}
