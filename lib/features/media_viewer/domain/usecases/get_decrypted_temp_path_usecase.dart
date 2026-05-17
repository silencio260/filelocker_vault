import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/vault_error_handler.dart';
import '../../../../core/services/encryption_service.dart';

class DecryptToTempParams {
  final String encryptedPath;
  final String iv;
  final String fileName;
  const DecryptToTempParams({
    required this.encryptedPath,
    required this.iv,
    required this.fileName,
  });
}

class GetDecryptedTempPathUseCase {
  final EncryptionService encryptionService;
  GetDecryptedTempPathUseCase({required this.encryptionService});

  Future<Either<Failure, String>> call(DecryptToTempParams params) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/${params.fileName}';

      final result = await encryptionService.decryptFileInIsolate(
        params.encryptedPath,
        tempPath,
        params.iv,
      );

      if (!result.success || result.decryptedPath == null) {
        return Left(FileOperationFailure(result.error ?? 'Decryption failed'));
      }
      return Right(result.decryptedPath!);
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }
}
