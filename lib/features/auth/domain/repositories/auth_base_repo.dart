import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/auth_entity.dart';
import '../entities/lockout_state_entity.dart';

abstract class AuthBaseRepo {
  Future<Either<Failure, bool>> isFirstTime();
  Future<Either<Failure, bool>> setupPin(String pin);
  Future<Either<Failure, bool>> verifyPin(String pin);
  Future<Either<Failure, bool>> isBiometricAvailable();
  Future<Either<Failure, bool>> isBiometricEnabled();
  Future<Either<Failure, bool>> enableBiometric();
  Future<Either<Failure, bool>> authenticateWithBiometric();
  Future<Either<Failure, AuthEntity>> getAuthState();
  Future<Either<Failure, LockoutStateEntity>> getLockoutState();
  Future<Either<Failure, LockoutStateEntity>> registerFailedAttempt();
  Future<Either<Failure, bool>> resetFailedAttempts();
  Future<Either<Failure, bool>> changePin(String currentPin, String newPin);
}
