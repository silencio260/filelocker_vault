import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/album_entity.dart';
import '../repositories/vault_base_repo.dart';

class AddFileToAlbumParams {
  final String fileId;
  final String albumId;
  const AddFileToAlbumParams({required this.fileId, required this.albumId});
}

class AddFileToAlbumUseCase extends BaseUseCase<AlbumEntity, AddFileToAlbumParams> {
  final VaultBaseRepo repo;
  AddFileToAlbumUseCase({required this.repo});

  @override
  Future<Either<Failure, AlbumEntity>> call(AddFileToAlbumParams params) =>
      repo.addFileToAlbum(params.fileId, params.albumId);
}
