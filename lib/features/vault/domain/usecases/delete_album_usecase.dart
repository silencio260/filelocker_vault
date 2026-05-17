import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/vault_base_repo.dart';

class DeleteAlbumParams {
  final String albumId;
  const DeleteAlbumParams({required this.albumId});
}

class DeleteAlbumUseCase extends BaseUseCase<bool, DeleteAlbumParams> {
  final VaultBaseRepo repo;
  DeleteAlbumUseCase({required this.repo});

  @override
  Future<Either<Failure, bool>> call(DeleteAlbumParams params) =>
      repo.deleteAlbum(params.albumId);
}
