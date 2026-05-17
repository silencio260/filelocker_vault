import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/vault_error_handler.dart';
import '../../../../core/services/encryption_service.dart';

class DecryptFileParams {
  final String encryptedPath;
  final String iv;
  const DecryptFileParams({required this.encryptedPath, required this.iv});
}

class DecryptFileToMemoryUseCase {
  final EncryptionService encryptionService;
  DecryptFileToMemoryUseCase({required this.encryptionService});

  Future<Either<Failure, Uint8List>> call(DecryptFileParams params) async {
    try {
      final result = await encryptionService.decryptFileToMemory(
        params.encryptedPath,
        params.iv,
      );
      if (!result.success || result.data == null) {
        return Left(FileOperationFailure(result.error ?? 'Decryption failed'));
      }
      return Right(result.data!);
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }
}
