import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/vault_base_repo.dart';

class ExportFileParams {
  final String fileId;
  final String destinationPath;
  const ExportFileParams({required this.fileId, required this.destinationPath});
}

class ExportFileUseCase extends BaseUseCase<bool, ExportFileParams> {
  final VaultBaseRepo repo;
  ExportFileUseCase({required this.repo});

  @override
  Future<Either<Failure, bool>> call(ExportFileParams params) =>
      repo.exportFile(params.fileId, params.destinationPath);
}
