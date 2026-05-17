import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/vaulted_file_entity.dart';
import '../repositories/vault_base_repo.dart';

class ToggleFavoriteParams {
  final String fileId;
  const ToggleFavoriteParams({required this.fileId});
}

class ToggleFavoriteUseCase extends BaseUseCase<VaultedFileEntity, ToggleFavoriteParams> {
  final VaultBaseRepo repo;
  ToggleFavoriteUseCase({required this.repo});

  @override
  Future<Either<Failure, VaultedFileEntity>> call(ToggleFavoriteParams params) =>
      repo.toggleFavorite(params.fileId);
}
