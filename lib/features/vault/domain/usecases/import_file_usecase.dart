import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/vaulted_file_entity.dart';
import '../repositories/vault_base_repo.dart';

class ImportFileParams {
  final String sourcePath;
  final String? identifier;
  const ImportFileParams({required this.sourcePath, this.identifier});
}

class ImportFileUseCase extends BaseUseCase<VaultedFileEntity, ImportFileParams> {
  final VaultBaseRepo repo;
  ImportFileUseCase({required this.repo});

  @override
  Future<Either<Failure, VaultedFileEntity>> call(ImportFileParams params) =>
      repo.importFile(params.sourcePath, identifier: params.identifier);
}
