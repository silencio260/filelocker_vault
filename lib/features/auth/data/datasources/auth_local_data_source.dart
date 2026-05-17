import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'auth_base_local_data_source.dart';

class AuthLocalDataSource implements AuthBaseLocalDataSource {
  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth = LocalAuthentication();

  static const String _pinHashKey = 'user_pin_hash';
  static const String _firstTimeKey = 'is_first_time';
  static const String _biometricsEnabledKey = 'biometrics_enabled';
  static const String _authMethodKey = 'auth_method';
  static const String _failedAttemptsKey = 'failed_unlock_attempts';
  static const String _lockoutUntilKey = 'unlock_lockout_until';

  static const int _maxAttempts = 5;
  static const int _lockoutSeconds = 30;

  AuthLocalDataSource({required FlutterSecureStorage storage})
      : _storage = storage;

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  @override
  Future<bool> isFirstTime() async {
    final value = await _storage.read(key: _firstTimeKey);
    return value == null || value == 'true';
  }

  @override
  Future<bool> setupPin(String pin) async {
    if (pin.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(pin)) {
      return false;
    }
    await _storage.write(key: _pinHashKey, value: _hashPin(pin));
    await _storage.write(key: _firstTimeKey, value: 'false');
    await _storage.write(key: _authMethodKey, value: 'pin');
    return true;
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: _pinHashKey);
    if (stored == null) return false;
    return _hashPin(pin) == stored;
  }

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricsEnabledKey);
    return value == 'true';
  }

  @override
  Future<bool> enableBiometric() async {
    try {
      final available = await isBiometricAvailable();
      if (!available) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Set up biometric authentication',
        options: const AuthenticationOptions(biometricOnly: false),
      );

      if (authenticated) {
        await _storage.write(key: _biometricsEnabledKey, value: 'true');
      }
      return authenticated;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> authenticateWithBiometric() async {
    try {
      final enabled = await isBiometricEnabled();
      if (!enabled) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your vault',
        options: const AuthenticationOptions(biometricOnly: false),
      );
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getAuthState() async {
    final method = await _storage.read(key: _authMethodKey) ?? 'none';
    final firstTime = await isFirstTime();
    final biometricEnabled = await isBiometricEnabled();
    final failedAttempts =
        int.tryParse(await _storage.read(key: _failedAttemptsKey) ?? '') ?? 0;
    final lockoutMillis =
        int.tryParse(await _storage.read(key: _lockoutUntilKey) ?? '');
    final lockoutUntil = lockoutMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(lockoutMillis).toIso8601String()
        : null;

    return {
      'authMethod': method,
      'biometricEnabled': biometricEnabled,
      'isFirstTime': firstTime,
      'failedAttempts': failedAttempts,
      'lockoutUntil': lockoutUntil,
    };
  }

  @override
  Future<Map<String, dynamic>> getLockoutState() async {
    final failedAttempts =
        int.tryParse(await _storage.read(key: _failedAttemptsKey) ?? '') ?? 0;
    final lockoutMillis =
        int.tryParse(await _storage.read(key: _lockoutUntilKey) ?? '');
    DateTime? lockoutUntil = lockoutMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(lockoutMillis)
        : null;

    // Clear expired lockout
    if (lockoutUntil != null && lockoutUntil.isBefore(DateTime.now())) {
      lockoutUntil = null;
      await _storage.delete(key: _lockoutUntilKey);
    }

    final isLockedOut = lockoutUntil?.isAfter(DateTime.now()) ?? false;
    final remainingMs = isLockedOut
        ? lockoutUntil!.difference(DateTime.now()).inMilliseconds
        : 0;
    final attemptsRemaining =
        isLockedOut ? 0 : (_maxAttempts - failedAttempts).clamp(0, _maxAttempts);

    return {
      'isLockedOut': isLockedOut,
      'remainingLockoutMs': remainingMs,
      'attemptsRemaining': attemptsRemaining,
      'protectionEnabled': true,
    };
  }

  @override
  Future<Map<String, dynamic>> registerFailedAttempt() async {
    var attempts =
        int.tryParse(await _storage.read(key: _failedAttemptsKey) ?? '') ?? 0;
    attempts++;

    if (attempts >= _maxAttempts) {
      final lockoutUntil =
          DateTime.now().add(const Duration(seconds: _lockoutSeconds));
      await _storage.write(
          key: _lockoutUntilKey,
          value: lockoutUntil.millisecondsSinceEpoch.toString());
      await _storage.write(key: _failedAttemptsKey, value: '0');
      return {
        'isLockedOut': true,
        'remainingLockoutMs': _lockoutSeconds * 1000,
        'attemptsRemaining': 0,
        'protectionEnabled': true,
      };
    }

    await _storage.write(key: _failedAttemptsKey, value: attempts.toString());
    return {
      'isLockedOut': false,
      'remainingLockoutMs': 0,
      'attemptsRemaining': _maxAttempts - attempts,
      'protectionEnabled': true,
    };
  }

  @override
  Future<bool> resetFailedAttempts() async {
    await _storage.delete(key: _failedAttemptsKey);
    await _storage.delete(key: _lockoutUntilKey);
    return true;
  }

  @override
  Future<bool> changePin(String currentPin, String newPin) async {
    if (!await verifyPin(currentPin)) return false;
    return setupPin(newPin);
  }
}
