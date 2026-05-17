import '../../domain/entities/vaulted_file_entity.dart';
import '../models/album_model.dart';
import '../models/vaulted_file_model.dart';

abstract class VaultBaseLocalDataSource {
  Future<void> initializeVault();
  Future<List<VaultedFileModel>> getFiles();
  Future<List<VaultedFileModel>> getFilesByType(VaultedFileType type);
  Future<VaultedFileModel> importFile(String sourcePath, {String? identifier});
  Future<bool> deleteFile(String fileId);
  Future<bool> exportFile(String fileId, String destinationPath);
  Future<VaultedFileModel> toggleFavorite(String fileId);
  Future<List<AlbumModel>> getAlbums();
  Future<AlbumModel> createAlbum(String name);
  Future<bool> deleteAlbum(String albumId);
  Future<AlbumModel> addFileToAlbum(String fileId, String albumId);
  Future<AlbumModel> removeFileFromAlbum(String fileId, String albumId);
  Future<List<VaultedFileModel>> getFilesForAlbum(String albumId);
}
