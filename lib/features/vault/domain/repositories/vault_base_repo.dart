import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/album_entity.dart';
import '../entities/vaulted_file_entity.dart';

abstract class VaultBaseRepo {
  Future<Either<Failure, bool>> initializeVault();
  Future<Either<Failure, List<VaultedFileEntity>>> getFiles();
  Future<Either<Failure, List<VaultedFileEntity>>> getFilesByType(
      VaultedFileType type);
  Future<Either<Failure, VaultedFileEntity>> importFile(String sourcePath, {String? identifier});
  Future<Either<Failure, bool>> deleteFile(String fileId);
  Future<Either<Failure, bool>> exportFile(
      String fileId, String destinationPath);
  Future<Either<Failure, VaultedFileEntity>> toggleFavorite(String fileId);
  Future<Either<Failure, List<AlbumEntity>>> getAlbums();
  Future<Either<Failure, AlbumEntity>> createAlbum(String name);
  Future<Either<Failure, bool>> deleteAlbum(String albumId);
  Future<Either<Failure, AlbumEntity>> addFileToAlbum(
      String fileId, String albumId);
  Future<Either<Failure, AlbumEntity>> removeFileFromAlbum(
      String fileId, String albumId);
  Future<Either<Failure, List<VaultedFileEntity>>> getFilesForAlbum(
      String albumId);
}
