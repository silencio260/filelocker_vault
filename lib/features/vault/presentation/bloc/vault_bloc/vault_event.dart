import 'package:equatable/equatable.dart';
import '../../../domain/entities/album_entity.dart';
import '../../../domain/entities/vaulted_file_entity.dart';

abstract class VaultEvent extends Equatable {
  const VaultEvent();

  @override
  List<Object?> get props => [];
}

class VaultInitializeEvent extends VaultEvent {
  const VaultInitializeEvent();
}

class VaultLoadFilesEvent extends VaultEvent {
  const VaultLoadFilesEvent();
}

class VaultImportFileEvent extends VaultEvent {
  final String sourcePath;
  // Content URI (Android) or PHAsset identifier (iOS) from file_picker.
  // Used to delete the original from the system media library after import.
  final String? identifier;
  const VaultImportFileEvent(this.sourcePath, {this.identifier});

  @override
  List<Object?> get props => [sourcePath, identifier];
}

class VaultDeleteFileEvent extends VaultEvent {
  final String fileId;
  const VaultDeleteFileEvent(this.fileId);

  @override
  List<Object?> get props => [fileId];
}

class VaultExportFileEvent extends VaultEvent {
  final String fileId;
  final String destinationPath;
  const VaultExportFileEvent(this.fileId, this.destinationPath);

  @override
  List<Object?> get props => [fileId, destinationPath];
}

class VaultToggleFavoriteEvent extends VaultEvent {
  final String fileId;
  const VaultToggleFavoriteEvent(this.fileId);

  @override
  List<Object?> get props => [fileId];
}

class VaultFilterByTypeEvent extends VaultEvent {
  final VaultedFileType? type;
  const VaultFilterByTypeEvent(this.type);

  @override
  List<Object?> get props => [type];
}

class VaultSearchEvent extends VaultEvent {
  final String query;
  const VaultSearchEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class VaultSortEvent extends VaultEvent {
  final SortOption sortOption;
  const VaultSortEvent(this.sortOption);

  @override
  List<Object?> get props => [sortOption];
}
