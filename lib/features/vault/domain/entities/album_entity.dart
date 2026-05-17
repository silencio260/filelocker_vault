import 'package:equatable/equatable.dart';

enum AlbumType {
  custom,
  favorites,
  recent,
  screenshots,
  camera,
  downloads;

  String get displayName {
    switch (this) {
      case AlbumType.custom:
        return 'Album';
      case AlbumType.favorites:
        return 'Favorites';
      case AlbumType.recent:
        return 'Recent';
      case AlbumType.screenshots:
        return 'Screenshots';
      case AlbumType.camera:
        return 'Camera';
      case AlbumType.downloads:
        return 'Downloads';
    }
  }

  static AlbumType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'favorites':
        return AlbumType.favorites;
      case 'recent':
        return AlbumType.recent;
      case 'screenshots':
        return AlbumType.screenshots;
      case 'camera':
        return AlbumType.camera;
      case 'downloads':
        return AlbumType.downloads;
      default:
        return AlbumType.custom;
    }
  }
}

enum SortOption {
  nameAsc,
  nameDesc,
  dateAddedNewest,
  dateAddedOldest,
  sizeSmallest,
  sizeLargest;

  String get displayName {
    switch (this) {
      case SortOption.nameAsc:
        return 'Name (A-Z)';
      case SortOption.nameDesc:
        return 'Name (Z-A)';
      case SortOption.dateAddedNewest:
        return 'Newest First';
      case SortOption.dateAddedOldest:
        return 'Oldest First';
      case SortOption.sizeSmallest:
        return 'Smallest First';
      case SortOption.sizeLargest:
        return 'Largest First';
    }
  }
}

class AlbumEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? coverImageId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> fileIds;
  final bool isDefault;
  final AlbumType type;
  final int sortOrder;

  const AlbumEntity({
    required this.id,
    required this.name,
    this.description,
    this.coverImageId,
    required this.createdAt,
    required this.updatedAt,
    this.fileIds = const [],
    this.isDefault = false,
    this.type = AlbumType.custom,
    this.sortOrder = 0,
  });

  int get fileCount => fileIds.length;
  bool get isEmpty => fileIds.isEmpty;
  bool containsFile(String fileId) => fileIds.contains(fileId);

  AlbumEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImageId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? fileIds,
    bool? isDefault,
    AlbumType? type,
    int? sortOrder,
  }) {
    return AlbumEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageId: coverImageId ?? this.coverImageId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fileIds: fileIds ?? List.from(this.fileIds),
      isDefault: isDefault ?? this.isDefault,
      type: type ?? this.type,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  AlbumEntity addFile(String fileId) {
    if (fileIds.contains(fileId)) return this;
    return copyWith(
        fileIds: [...fileIds, fileId], updatedAt: DateTime.now());
  }

  AlbumEntity removeFile(String fileId) {
    return copyWith(
      fileIds: fileIds.where((id) => id != fileId).toList(),
      updatedAt: DateTime.now(),
      coverImageId: coverImageId == fileId ? null : coverImageId,
    );
  }

  @override
  List<Object?> get props => [id];
}
