import '../../domain/entities/vaulted_file_entity.dart';

class VaultedFileModel extends VaultedFileEntity {
  const VaultedFileModel({
    required super.id,
    required super.originalName,
    required super.vaultPath,
    super.originalPath,
    required super.type,
    required super.mimeType,
    required super.fileSize,
    required super.dateAdded,
    super.dateModified,
    super.thumbnailPath,
    super.tags,
    super.isFavorite,
    super.isEncrypted,
    super.encryptionIv,
    super.lastViewed,
    super.viewCount,
    super.notes,
    super.albumIds,
  });

  factory VaultedFileModel.fromJson(Map<String, dynamic> json) {
    return VaultedFileModel(
      id: json['id'] as String,
      originalName: json['originalName'] as String,
      vaultPath: json['vaultPath'] as String,
      originalPath: json['originalPath'] as String?,
      type: VaultedFileType.fromString(json['type'] as String),
      mimeType: json['mimeType'] as String,
      fileSize: json['fileSize'] as int,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      dateModified: json['dateModified'] != null
          ? DateTime.parse(json['dateModified'] as String)
          : null,
      thumbnailPath: json['thumbnailPath'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      isFavorite: json['isFavorite'] as bool? ?? false,
      isEncrypted: json['isEncrypted'] as bool? ?? false,
      encryptionIv: json['encryptionIv'] as String?,
      lastViewed: json['lastViewed'] != null
          ? DateTime.parse(json['lastViewed'] as String)
          : null,
      viewCount: json['viewCount'] as int? ?? 0,
      notes: json['notes'] as String?,
      albumIds: (json['albumIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalName': originalName,
      'vaultPath': vaultPath,
      'originalPath': originalPath,
      'type': type.name,
      'mimeType': mimeType,
      'fileSize': fileSize,
      'dateAdded': dateAdded.toIso8601String(),
      'dateModified': dateModified?.toIso8601String(),
      'thumbnailPath': thumbnailPath,
      'tags': tags,
      'isFavorite': isFavorite,
      'isEncrypted': isEncrypted,
      'encryptionIv': encryptionIv,
      'lastViewed': lastViewed?.toIso8601String(),
      'viewCount': viewCount,
      'notes': notes,
      'albumIds': albumIds,
    };
  }

  factory VaultedFileModel.fromEntity(VaultedFileEntity entity) {
    return VaultedFileModel(
      id: entity.id,
      originalName: entity.originalName,
      vaultPath: entity.vaultPath,
      originalPath: entity.originalPath,
      type: entity.type,
      mimeType: entity.mimeType,
      fileSize: entity.fileSize,
      dateAdded: entity.dateAdded,
      dateModified: entity.dateModified,
      thumbnailPath: entity.thumbnailPath,
      tags: entity.tags,
      isFavorite: entity.isFavorite,
      isEncrypted: entity.isEncrypted,
      encryptionIv: entity.encryptionIv,
      lastViewed: entity.lastViewed,
      viewCount: entity.viewCount,
      notes: entity.notes,
      albumIds: entity.albumIds,
    );
  }
}
