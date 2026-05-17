import '../../domain/entities/album_entity.dart';

class AlbumModel extends AlbumEntity {
  const AlbumModel({
    required super.id,
    required super.name,
    super.description,
    super.coverImageId,
    required super.createdAt,
    required super.updatedAt,
    super.fileIds,
    super.isDefault,
    super.type,
    super.sortOrder,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverImageId: json['coverImageId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      fileIds: (json['fileIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      isDefault: json['isDefault'] as bool? ?? false,
      type: AlbumType.fromString(json['type'] as String? ?? 'custom'),
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverImageId': coverImageId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'fileIds': fileIds,
      'isDefault': isDefault,
      'type': type.name,
      'sortOrder': sortOrder,
    };
  }

  factory AlbumModel.fromEntity(AlbumEntity entity) {
    return AlbumModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      coverImageId: entity.coverImageId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      fileIds: entity.fileIds,
      isDefault: entity.isDefault,
      type: entity.type,
      sortOrder: entity.sortOrder,
    );
  }
}
