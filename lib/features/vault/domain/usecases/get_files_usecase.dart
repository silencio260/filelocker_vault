import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/vaulted_file_entity.dart';
import '../repositories/vault_base_repo.dart';

class GetFilesUseCase extends BaseUseCase<List<VaultedFileEntity>, NoParams> {
  final VaultBaseRepo repo;
  GetFilesUseCase({required this.repo});

  @override
  Future<Either<Failure, List<VaultedFileEntity>>> call(NoParams params) =>
      repo.getFiles();
}
