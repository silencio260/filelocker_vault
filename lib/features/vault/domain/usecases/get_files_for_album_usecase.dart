import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/vaulted_file_entity.dart';
import '../repositories/vault_base_repo.dart';

class GetFilesForAlbumParams {
  final String albumId;
  const GetFilesForAlbumParams({required this.albumId});
}

class GetFilesForAlbumUseCase
    extends BaseUseCase<List<VaultedFileEntity>, GetFilesForAlbumParams> {
  final VaultBaseRepo repo;
  GetFilesForAlbumUseCase({required this.repo});

  @override
  Future<Either<Failure, List<VaultedFileEntity>>> call(
          GetFilesForAlbumParams params) =>
      repo.getFilesForAlbum(params.albumId);
}
