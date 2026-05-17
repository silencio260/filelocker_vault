import 'package:equatable/equatable.dart';
import '../../../domain/entities/album_entity.dart';
import '../../../domain/entities/vaulted_file_entity.dart';

abstract class VaultState extends Equatable {
  const VaultState();

  @override
  List<Object?> get props => [];
}

class VaultInitial extends VaultState {
  const VaultInitial();
}

class VaultLoading extends VaultState {
  const VaultLoading();
}

class VaultLoaded extends VaultState {
  final List<VaultedFileEntity> files;
  final VaultedFileType? activeFilter;
  final SortOption sortOption;
  final String searchQuery;

  const VaultLoaded({
    required this.files,
    this.activeFilter,
    this.sortOption = SortOption.dateAddedNewest,
    this.searchQuery = '',
  });

  List<VaultedFileEntity> get displayFiles {
    var result = files;

    if (activeFilter != null) {
      result = result.where((f) => f.type == activeFilter).toList();
    }

    if (searchQuery.isNotEmpty) {
      final lower = searchQuery.toLowerCase();
      result = result
          .where((f) => f.originalName.toLowerCase().contains(lower))
          .toList();
    }

    return _sortFiles(result, sortOption);
  }

  List<VaultedFileEntity> _sortFiles(
      List<VaultedFileEntity> list, SortOption option) {
    final sorted = List<VaultedFileEntity>.from(list);
    switch (option) {
      case SortOption.nameAsc:
        sorted.sort((a, b) =>
            a.originalName.toLowerCase().compareTo(b.originalName.toLowerCase()));
        break;
      case SortOption.nameDesc:
        sorted.sort((a, b) =>
            b.originalName.toLowerCase().compareTo(a.originalName.toLowerCase()));
        break;
      case SortOption.dateAddedNewest:
        sorted.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case SortOption.dateAddedOldest:
        sorted.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
        break;
      case SortOption.sizeSmallest:
        sorted.sort((a, b) => a.fileSize.compareTo(b.fileSize));
        break;
      case SortOption.sizeLargest:
        sorted.sort((a, b) => b.fileSize.compareTo(a.fileSize));
        break;
    }
    return sorted;
  }

  VaultLoaded copyWith({
    List<VaultedFileEntity>? files,
    VaultedFileType? activeFilter,
    bool clearFilter = false,
    SortOption? sortOption,
    String? searchQuery,
  }) {
    return VaultLoaded(
      files: files ?? this.files,
      activeFilter: clearFilter ? null : activeFilter ?? this.activeFilter,
      sortOption: sortOption ?? this.sortOption,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [files, activeFilter, sortOption, searchQuery];
}

class VaultImporting extends VaultState {
  final double progress;
  const VaultImporting({this.progress = 0.0});

  @override
  List<Object?> get props => [progress];
}

class VaultOperationSuccess extends VaultState {
  final String message;
  const VaultOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class VaultError extends VaultState {
  final String message;
  const VaultError(this.message);

  @override
  List<Object?> get props => [message];
}
