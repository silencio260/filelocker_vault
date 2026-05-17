import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/album_entity.dart';
import '../repositories/vault_base_repo.dart';

class RemoveFileFromAlbumParams {
  final String fileId;
  final String albumId;
  const RemoveFileFromAlbumParams({required this.fileId, required this.albumId});
}

class RemoveFileFromAlbumUseCase extends BaseUseCase<AlbumEntity, RemoveFileFromAlbumParams> {
  final VaultBaseRepo repo;
  RemoveFileFromAlbumUseCase({required this.repo});

  @override
  Future<Either<Failure, AlbumEntity>> call(RemoveFileFromAlbumParams params) =>
      repo.removeFileFromAlbum(params.fileId, params.albumId);
}
