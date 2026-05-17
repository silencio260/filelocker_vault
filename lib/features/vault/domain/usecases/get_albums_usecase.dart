import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/album_entity.dart';
import '../repositories/vault_base_repo.dart';

class GetAlbumsUseCase extends BaseUseCase<List<AlbumEntity>, NoParams> {
  final VaultBaseRepo repo;
  GetAlbumsUseCase({required this.repo});

  @override
  Future<Either<Failure, List<AlbumEntity>>> call(NoParams params) =>
      repo.getAlbums();
}
