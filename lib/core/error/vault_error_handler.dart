import 'dart:io';
import 'package:flutter/services.dart';
import 'failure.dart';

Failure handleVaultException(Object e) {
  if (e is PlatformException) {
    if (e.code == 'NotAvailable' || e.code == 'NotEnrolled') {
      return AuthFailure('Biometric not available: ${e.message}');
    }
    if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
      return AuthFailure('Biometric locked out');
    }
    if (e.code == 'UserCanceled' || e.code == 'Canceled') {
      return AuthFailure('Authentication cancelled');
    }
    return AuthFailure(e.message ?? 'Platform error');
  }

  if (e is FileSystemException) {
    return FileOperationFailure(e.message);
  }

  if (e is Exception) {
    final msg = e.toString();
    if (msg.contains('permission') || msg.contains('Permission')) {
      return const PermissionFailure();
    }
    if (msg.contains('storage') || msg.contains('Storage')) {
      return StorageFailure(msg);
    }
  }

  return UnknownFailure(e.toString());
}
