import 'package:equatable/equatable.dart';

enum VaultedFileType {
  image,
  video,
  document,
  other;

  String get displayName {
    switch (this) {
      case VaultedFileType.image:
        return 'Image';
      case VaultedFileType.video:
        return 'Video';
      case VaultedFileType.document:
        return 'Document';
      case VaultedFileType.other:
        return 'Other';
    }
  }

  static VaultedFileType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'image':
        return VaultedFileType.image;
      case 'video':
        return VaultedFileType.video;
      case 'document':
        return VaultedFileType.document;
      default:
        return VaultedFileType.other;
    }
  }

  static VaultedFileType fromMime(String mime) {
    if (mime.startsWith('image/')) return VaultedFileType.image;
    if (mime.startsWith('video/')) { return VaultedFileType.video; }
    if (mime.contains('pdf') ||
        mime.contains('word') ||
        mime.contains('document') ||
        mime.contains('text')) { return VaultedFileType.document; }
    return VaultedFileType.other;
  }
}

class VaultedFileEntity extends Equatable {
  final String id;
  final String originalName;
  final String vaultPath;
  final String? originalPath;
  final VaultedFileType type;
  final String mimeType;
  final int fileSize;
  final DateTime dateAdded;
  final DateTime? dateModified;
  final String? thumbnailPath;
  final List<String> tags;
  final bool isFavorite;
  final bool isEncrypted;
  final String? encryptionIv;
  final DateTime? lastViewed;
  final int viewCount;
  final String? notes;
  final List<String> albumIds;

  const VaultedFileEntity({
    required this.id,
    required this.originalName,
    required this.vaultPath,
    this.originalPath,
    required this.type,
    required this.mimeType,
    required this.fileSize,
    required this.dateAdded,
    this.dateModified,
    this.thumbnailPath,
    this.tags = const [],
    this.isFavorite = false,
    this.isEncrypted = false,
    this.encryptionIv,
    this.lastViewed,
    this.viewCount = 0,
    this.notes,
    this.albumIds = const [],
  });

  bool get isImage => type == VaultedFileType.image;
  bool get isVideo => type == VaultedFileType.video;
  bool get isDocument => type == VaultedFileType.document;

  String get extension {
    final parts = originalName.split('.');
    return parts.length > 1 ? '.${parts.last.toLowerCase()}' : '';
  }

  String get formattedSize {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  VaultedFileEntity copyWith({
    String? id,
    String? originalName,
    String? vaultPath,
    String? originalPath,
    VaultedFileType? type,
    String? mimeType,
    int? fileSize,
    DateTime? dateAdded,
    DateTime? dateModified,
    String? thumbnailPath,
    List<String>? tags,
    bool? isFavorite,
    bool? isEncrypted,
    String? encryptionIv,
    DateTime? lastViewed,
    int? viewCount,
    String? notes,
    List<String>? albumIds,
  }) {
    return VaultedFileEntity(
      id: id ?? this.id,
      originalName: originalName ?? this.originalName,
      vaultPath: vaultPath ?? this.vaultPath,
      originalPath: originalPath ?? this.originalPath,
      type: type ?? this.type,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      tags: tags ?? List.from(this.tags),
      isFavorite: isFavorite ?? this.isFavorite,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      encryptionIv: encryptionIv ?? this.encryptionIv,
      lastViewed: lastViewed ?? this.lastViewed,
      viewCount: viewCount ?? this.viewCount,
      notes: notes ?? this.notes,
      albumIds: albumIds ?? List.from(this.albumIds),
    );
  }

  VaultedFileEntity toggleFavorite() => copyWith(isFavorite: !isFavorite);

  VaultedFileEntity addToAlbum(String albumId) {
    if (albumIds.contains(albumId)) return this;
    return copyWith(albumIds: [...albumIds, albumId]);
  }

  VaultedFileEntity removeFromAlbum(String albumId) {
    return copyWith(albumIds: albumIds.where((id) => id != albumId).toList());
  }

  @override
  List<Object?> get props => [id];
}
