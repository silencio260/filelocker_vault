import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/vault_error_handler.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/lockout_state_entity.dart';
import '../../domain/repositories/auth_base_repo.dart';
import '../datasources/auth_base_local_data_source.dart';
import '../models/auth_model.dart';

class AuthRepo implements AuthBaseRepo {
  final AuthBaseLocalDataSource _dataSource;

  AuthRepo({required AuthBaseLocalDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<Failure, bool>> isFirstTime() async {
    try {
      return Right(await _dataSource.isFirstTime());
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> setupPin(String pin) async {
    try {
      return Right(await _dataSource.setupPin(pin));
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPin(String pin) async {
    try {
      return Right(await _dataSource.verifyPin(pin));
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isBiometricAvailable() async {
    try {
      return Right(await _dataSource.isBiometricAvailable());
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isBiometricEnabled() async {
    try {
      return Right(await _dataSource.isBiometricEnabled());
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> enableBiometric() async {
    try {
      return Right(await _dataSource.enableBiometric());
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> authenticateWithBiometric() async {
    try {
      return Right(await _dataSource.authenticateWithBiometric());
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getAuthState() async {
    try {
      final json = await _dataSource.getAuthState();
      return Right(AuthModel.fromJson(json));
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, LockoutStateEntity>> getLockoutState() async {
    try {
      final json = await _dataSource.getLockoutState();
      return Right(_lockoutFromJson(json));
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, LockoutStateEntity>> registerFailedAttempt() async {
    try {
      final json = await _dataSource.registerFailedAttempt();
      return Right(_lockoutFromJson(json));
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> resetFailedAttempts() async {
    try {
      return Right(await _dataSource.resetFailedAttempts());
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> changePin(
      String currentPin, String newPin) async {
    try {
      return Right(await _dataSource.changePin(currentPin, newPin));
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  LockoutStateEntity _lockoutFromJson(Map<String, dynamic> json) {
    return LockoutStateEntity(
      isLockedOut: json['isLockedOut'] as bool? ?? false,
      remainingLockout:
          Duration(milliseconds: json['remainingLockoutMs'] as int? ?? 0),
      attemptsRemaining: json['attemptsRemaining'] as int? ?? 5,
      protectionEnabled: json['protectionEnabled'] as bool? ?? true,
    );
  }
}
