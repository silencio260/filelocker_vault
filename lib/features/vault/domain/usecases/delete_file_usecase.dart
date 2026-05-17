import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/vault_base_repo.dart';

class DeleteFileParams {
  final String fileId;
  const DeleteFileParams({required this.fileId});
}

class DeleteFileUseCase extends BaseUseCase<bool, DeleteFileParams> {
  final VaultBaseRepo repo;
  DeleteFileUseCase({required this.repo});

  @override
  Future<Either<Failure, bool>> call(DeleteFileParams params) =>
      repo.deleteFile(params.fileId);
}
