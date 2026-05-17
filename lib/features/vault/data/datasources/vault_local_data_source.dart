import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/encryption_service.dart';
import '../../../../core/services/media_platform_service.dart';
import '../../domain/entities/album_entity.dart';
import '../../domain/entities/vaulted_file_entity.dart';
import '../models/album_model.dart';
import '../models/vaulted_file_model.dart';
import 'vault_base_local_data_source.dart';

class VaultLocalDataSource implements VaultBaseLocalDataSource {
  final FlutterSecureStorage _storage;
  final EncryptionService _encryptionService;
  final MediaPlatformService _mediaService;

  static const String _vaultIndexKey = 'vault_file_index';
  static const String _albumsKey = 'vault_albums';
  static const String _vaultFolderName = '.filelocker_vault';

  Directory? _vaultDirectory;
  List<VaultedFileModel>? _cachedFiles;
  List<AlbumModel>? _cachedAlbums;

  VaultLocalDataSource({
    required FlutterSecureStorage storage,
    required EncryptionService encryptionService,
    MediaPlatformService? mediaService,
  })  : _storage = storage,
        _encryptionService = encryptionService,
        _mediaService = mediaService ?? MediaPlatformService();

  @override
  Future<void> initializeVault() async {
    await _encryptionService.initialize();
    await _ensureVaultDirectory();
    await _loadFileIndex();
    await _loadAlbums();
  }

  Future<Directory> _ensureVaultDirectory() async {
    if (_vaultDirectory != null && await _vaultDirectory!.exists()) {
      return _vaultDirectory!;
    }

    final appDir = await getApplicationDocumentsDirectory();
    _vaultDirectory = Directory('${appDir.path}/$_vaultFolderName');

    if (!await _vaultDirectory!.exists()) {
      await _vaultDirectory!.create(recursive: true);
    }

    await Directory('${_vaultDirectory!.path}/images').create(recursive: true);
    await Directory('${_vaultDirectory!.path}/videos').create(recursive: true);
    await Directory('${_vaultDirectory!.path}/documents').create(recursive: true);
    await Directory('${_vaultDirectory!.path}/thumbnails').create(recursive: true);
    await Directory('${_vaultDirectory!.path}/temp').create(recursive: true);

    final noMedia = File('${_vaultDirectory!.path}/.nomedia');
    if (!await noMedia.exists()) await noMedia.create();

    return _vaultDirectory!;
  }

  String _getSubdirectory(VaultedFileType type) {
    switch (type) {
      case VaultedFileType.image:
        return 'images';
      case VaultedFileType.video:
        return 'videos';
      case VaultedFileType.document:
      case VaultedFileType.other:
        return 'documents';
    }
  }

  Future<List<VaultedFileModel>> _loadFileIndex() async {
    if (_cachedFiles != null) return _cachedFiles!;
    try {
      final json = await _storage.read(key: _vaultIndexKey);
      if (json == null || json.isEmpty) {
        _cachedFiles = [];
        return _cachedFiles!;
      }
      final list = jsonDecode(json) as List<dynamic>;
      _cachedFiles = list
          .map((e) => VaultedFileModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return _cachedFiles!;
    } catch (e) {
      debugPrint('Error loading vault index: $e');
      _cachedFiles = [];
      return _cachedFiles!;
    }
  }

  Future<void> _saveFileIndex() async {
    try {
      final list = _cachedFiles?.map((f) => f.toJson()).toList() ?? [];
      await _storage.write(key: _vaultIndexKey, value: jsonEncode(list));
    } catch (e) {
      debugPrint('Error saving vault index: $e');
    }
  }

  Future<List<AlbumModel>> _loadAlbums() async {
    if (_cachedAlbums != null) return _cachedAlbums!;
    try {
      final json = await _storage.read(key: _albumsKey);
      if (json == null || json.isEmpty) {
        _cachedAlbums = _createDefaultAlbums();
        await _saveAlbums();
        return _cachedAlbums!;
      }
      final list = jsonDecode(json) as List<dynamic>;
      _cachedAlbums = list
          .map((e) => AlbumModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return _cachedAlbums!;
    } catch (e) {
      debugPrint('Error loading albums: $e');
      _cachedAlbums = _createDefaultAlbums();
      return _cachedAlbums!;
    }
  }

  Future<void> _saveAlbums() async {
    try {
      final list = _cachedAlbums?.map((a) => a.toJson()).toList() ?? [];
      await _storage.write(key: _albumsKey, value: jsonEncode(list));
    } catch (e) {
      debugPrint('Error saving albums: $e');
    }
  }

  List<AlbumModel> _createDefaultAlbums() {
    final now = DateTime.now();
    return [
      AlbumModel(
        id: 'favorites',
        name: 'Favorites',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
        type: AlbumType.favorites,
        sortOrder: 0,
      ),
      AlbumModel(
        id: 'recent',
        name: 'Recent',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
        type: AlbumType.recent,
        sortOrder: 1,
      ),
    ];
  }

  @override
  Future<List<VaultedFileModel>> getFiles() async {
    return await _loadFileIndex();
  }

  @override
  Future<List<VaultedFileModel>> getFilesByType(VaultedFileType type) async {
    final files = await _loadFileIndex();
    return files.where((f) => f.type == type).toList();
  }

  @override
  Future<VaultedFileModel> importFile(String sourcePath, {String? identifier}) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw FileSystemException('Source file does not exist', sourcePath);
    }

    final directory = await _ensureVaultDirectory();
    final originalName = sourcePath.split('/').last;
    final mimeType = lookupMimeType(sourcePath) ?? 'application/octet-stream';
    final type = VaultedFileType.fromMime(mimeType);
    final subdirectory = _getSubdirectory(type);

    final fileId = const Uuid().v4();
    final ext = originalName.contains('.') ? '.${originalName.split('.').last}' : '';
    final vaultFilename = '$fileId$ext';
    final vaultPath = '${directory.path}/$subdirectory/$vaultFilename';

    final fileSize = await sourceFile.length();

    final result = await _encryptionService.encryptFileInIsolate(
      sourcePath,
      vaultPath,
    );

    if (!result.success) {
      throw Exception('Encryption failed: ${result.error}');
    }

    // Delete the cache copy that file_picker placed in the app's temp directory.
    await sourceFile.delete();

    // On Android, file_picker copies the original to app cache; the original
    // still lives in the MediaStore. Use the content URI (identifier) to delete
    // it, then trigger a media scan so the gallery stops showing the file.
    if (identifier != null && identifier.startsWith('content://')) {
      await _mediaService.deleteMediaByUri(identifier);
    }
    await _mediaService.scanFile(sourcePath);

    final model = VaultedFileModel(
      id: fileId,
      originalName: originalName,
      vaultPath: vaultPath,
      originalPath: sourcePath,
      type: type,
      mimeType: mimeType,
      fileSize: fileSize,
      dateAdded: DateTime.now(),
      isEncrypted: true,
      encryptionIv: result.iv,
    );

    _cachedFiles ??= [];
    _cachedFiles!.add(model);
    await _saveFileIndex();

    return model;
  }

  @override
  Future<bool> deleteFile(String fileId) async {
    final files = await _loadFileIndex();
    final index = files.indexWhere((f) => f.id == fileId);
    if (index == -1) throw Exception('File not found: $fileId');

    final file = files[index];

    final vaultFile = File(file.vaultPath);
    if (await vaultFile.exists()) {
      await _encryptionService.secureDelete(file.vaultPath);
    }

    if (file.thumbnailPath != null) {
      final thumb = File(file.thumbnailPath!);
      if (await thumb.exists()) await thumb.delete();
    }

    for (final albumId in file.albumIds) {
      final albumIndex = _cachedAlbums?.indexWhere((a) => a.id == albumId) ?? -1;
      if (albumIndex != -1) {
        _cachedAlbums![albumIndex] = AlbumModel.fromEntity(
          _cachedAlbums![albumIndex].removeFile(fileId),
        );
      }
    }
    await _saveAlbums();

    _cachedFiles!.removeAt(index);
    await _saveFileIndex();

    return true;
  }

  @override
  Future<bool> exportFile(String fileId, String destinationPath) async {
    final files = await _loadFileIndex();
    final file = files.firstWhere(
      (f) => f.id == fileId,
      orElse: () => throw Exception('File not found: $fileId'),
    );

    final sourceFile = File(file.vaultPath);
    if (!await sourceFile.exists()) {
      throw FileSystemException('Vault file not found', file.vaultPath);
    }

    if (file.isEncrypted && file.encryptionIv != null) {
      final result = await _encryptionService.decryptFileInIsolate(
        file.vaultPath,
        destinationPath,
        file.encryptionIv!,
      );
      if (!result.success) throw Exception('Decryption failed: ${result.error}');
      return true;
    }

    await sourceFile.copy(destinationPath);
    return true;
  }

  @override
  Future<VaultedFileModel> toggleFavorite(String fileId) async {
    final files = await _loadFileIndex();
    final index = files.indexWhere((f) => f.id == fileId);
    if (index == -1) throw Exception('File not found: $fileId');

    final updated = VaultedFileModel.fromEntity(
      _cachedFiles![index].toggleFavorite(),
    );
    _cachedFiles![index] = updated;
    await _saveFileIndex();

    final favAlbumIndex = _cachedAlbums?.indexWhere((a) => a.id == 'favorites') ?? -1;
    if (favAlbumIndex != -1) {
      if (updated.isFavorite) {
        _cachedAlbums![favAlbumIndex] = AlbumModel.fromEntity(
          _cachedAlbums![favAlbumIndex].addFile(fileId),
        );
      } else {
        _cachedAlbums![favAlbumIndex] = AlbumModel.fromEntity(
          _cachedAlbums![favAlbumIndex].removeFile(fileId),
        );
      }
      await _saveAlbums();
    }

    return updated;
  }

  @override
  Future<List<AlbumModel>> getAlbums() async {
    return await _loadAlbums();
  }

  @override
  Future<AlbumModel> createAlbum(String name) async {
    await _loadAlbums();
    final now = DateTime.now();
    final id = sha256
        .convert(utf8.encode('$name${now.millisecondsSinceEpoch}'))
        .toString()
        .substring(0, 16);

    final album = AlbumModel(
      id: id,
      name: name,
      createdAt: now,
      updatedAt: now,
      sortOrder: (_cachedAlbums?.length ?? 0) + 1,
    );

    _cachedAlbums ??= [];
    _cachedAlbums!.add(album);
    await _saveAlbums();

    return album;
  }

  @override
  Future<bool> deleteAlbum(String albumId) async {
    final albums = await _loadAlbums();
    final albumIndex = albums.indexWhere((a) => a.id == albumId);
    if (albumIndex == -1) throw Exception('Album not found: $albumId');

    final album = albums[albumIndex];
    if (album.isDefault) throw Exception('Cannot delete default album');

    for (final fileId in album.fileIds) {
      final fileIndex = _cachedFiles?.indexWhere((f) => f.id == fileId) ?? -1;
      if (fileIndex != -1) {
        _cachedFiles![fileIndex] = VaultedFileModel.fromEntity(
          _cachedFiles![fileIndex].removeFromAlbum(albumId),
        );
      }
    }
    await _saveFileIndex();

    _cachedAlbums!.removeAt(albumIndex);
    await _saveAlbums();

    return true;
  }

  @override
  Future<AlbumModel> addFileToAlbum(String fileId, String albumId) async {
    await _loadFileIndex();
    await _loadAlbums();

    final fileIndex = _cachedFiles?.indexWhere((f) => f.id == fileId) ?? -1;
    if (fileIndex == -1) throw Exception('File not found: $fileId');

    final albumIndex = _cachedAlbums?.indexWhere((a) => a.id == albumId) ?? -1;
    if (albumIndex == -1) throw Exception('Album not found: $albumId');

    _cachedAlbums![albumIndex] = AlbumModel.fromEntity(
      _cachedAlbums![albumIndex].addFile(fileId),
    );
    await _saveAlbums();

    _cachedFiles![fileIndex] = VaultedFileModel.fromEntity(
      _cachedFiles![fileIndex].addToAlbum(albumId),
    );
    await _saveFileIndex();

    return _cachedAlbums![albumIndex];
  }

  @override
  Future<AlbumModel> removeFileFromAlbum(String fileId, String albumId) async {
    await _loadFileIndex();
    await _loadAlbums();

    final albumIndex = _cachedAlbums?.indexWhere((a) => a.id == albumId) ?? -1;
    if (albumIndex == -1) throw Exception('Album not found: $albumId');

    _cachedAlbums![albumIndex] = AlbumModel.fromEntity(
      _cachedAlbums![albumIndex].removeFile(fileId),
    );
    await _saveAlbums();

    final fileIndex = _cachedFiles?.indexWhere((f) => f.id == fileId) ?? -1;
    if (fileIndex != -1) {
      _cachedFiles![fileIndex] = VaultedFileModel.fromEntity(
        _cachedFiles![fileIndex].removeFromAlbum(albumId),
      );
      await _saveFileIndex();
    }

    return _cachedAlbums![albumIndex];
  }

  @override
  Future<List<VaultedFileModel>> getFilesForAlbum(String albumId) async {
    final albums = await _loadAlbums();
    final album = albums.firstWhere(
      (a) => a.id == albumId,
      orElse: () => throw Exception('Album not found: $albumId'),
    );

    final files = await _loadFileIndex();
    return files.where((f) => album.fileIds.contains(f.id)).toList();
  }
}
