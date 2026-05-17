import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/album_entity.dart';
import '../repositories/vault_base_repo.dart';

class CreateAlbumParams {
  final String name;
  const CreateAlbumParams({required this.name});
}

class CreateAlbumUseCase extends BaseUseCase<AlbumEntity, CreateAlbumParams> {
  final VaultBaseRepo repo;
  CreateAlbumUseCase({required this.repo});

  @override
  Future<Either<Failure, AlbumEntity>> call(CreateAlbumParams params) =>
      repo.createAlbum(params.name);
}
