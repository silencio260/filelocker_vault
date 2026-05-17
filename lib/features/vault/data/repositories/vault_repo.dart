import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/vault_error_handler.dart';
import '../../domain/entities/album_entity.dart';
import '../../domain/entities/vaulted_file_entity.dart';
import '../../domain/repositories/vault_base_repo.dart';
import '../datasources/vault_base_local_data_source.dart';

class VaultRepo implements VaultBaseRepo {
  final VaultBaseLocalDataSource dataSource;

  VaultRepo({required this.dataSource});

  @override
  Future<Either<Failure, bool>> initializeVault() async {
    try {
      await dataSource.initializeVault();
      return const Right(true);
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, List<VaultedFileEntity>>> getFiles() async {
    try {
      return Right(await dataSource.getFiles());
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, List<VaultedFileEntity>>> getFilesByType(
      VaultedFileType type) async {
    try {
      return Right(await dataSource.getFilesByType(type));
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, VaultedFileEntity>> importFile(
      String sourcePath, {String? identifier}) async {
    try {
      return Right(await dataSource.importFile(sourcePath, identifier: identifier));
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteFile(String fileId) async {
    try {
      return Right(await dataSource.deleteFile(fileId));
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> exportFile(
      String fileId, String destinationPath) async {
    try {
      return Right(await dataSource.exportFile(fileId, destinationPath));
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, VaultedFileEntity>> toggleFavorite(
      String fileId) async {
    try {
      return Right(await dataSource.toggleFavorite(fileId));
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, List<AlbumEntity>>> getAlbums() async {
    try {
      return Right(await dataSource.getAlbums());
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, AlbumEntity>> createAlbum(String name) async {
    try {
      return Right(await dataSource.createAlbum(name));
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAlbum(String albumId) async {
    try {
      return Right(await dataSource.deleteAlbum(albumId));
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, AlbumEntity>> addFileToAlbum(
      String fileId, String albumId) async {
    try {
      return Right(await dataSource.addFileToAlbum(fileId, albumId));
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, AlbumEntity>> removeFileFromAlbum(
      String fileId, String albumId) async {
    try {
      return Right(await dataSource.removeFileFromAlbum(fileId, albumId));
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }

  @override
  Future<Either<Failure, List<VaultedFileEntity>>> getFilesForAlbum(
      String albumId) async {
    try {
      return Right(await dataSource.getFilesForAlbum(albumId));
    } catch (e) {
      return Left(handleVaultException(e));
    }
  }
}
