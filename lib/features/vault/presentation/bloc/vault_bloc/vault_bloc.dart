import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/usecase/base_usecase.dart';
import '../../../domain/entities/album_entity.dart' show SortOption;
import '../../../domain/usecases/delete_file_usecase.dart';
import '../../../domain/usecases/export_file_usecase.dart';
import '../../../domain/usecases/get_files_usecase.dart';
import '../../../domain/usecases/import_file_usecase.dart';
import '../../../domain/usecases/initialize_vault_usecase.dart';
import '../../../domain/usecases/toggle_favorite_usecase.dart';
import 'vault_event.dart';
import 'vault_state.dart';

class VaultBloc extends Bloc<VaultEvent, VaultState> {
  final InitializeVaultUseCase initializeVault;
  final GetFilesUseCase getFiles;
  final ImportFileUseCase importFile;
  final DeleteFileUseCase deleteFile;
  final ExportFileUseCase exportFile;
  final ToggleFavoriteUseCase toggleFavorite;

  VaultBloc({
    required this.initializeVault,
    required this.getFiles,
    required this.importFile,
    required this.deleteFile,
    required this.exportFile,
    required this.toggleFavorite,
  }) : super(const VaultInitial()) {
    on<VaultInitializeEvent>(_onInitialize);
    on<VaultLoadFilesEvent>(_onLoadFiles);
    on<VaultImportFileEvent>(_onImportFile);
    on<VaultDeleteFileEvent>(_onDeleteFile);
    on<VaultExportFileEvent>(_onExportFile);
    on<VaultToggleFavoriteEvent>(_onToggleFavorite);
    on<VaultFilterByTypeEvent>(_onFilterByType);
    on<VaultSearchEvent>(_onSearch);
    on<VaultSortEvent>(_onSort);
  }

  Future<void> _onInitialize(
      VaultInitializeEvent event, Emitter<VaultState> emit) async {
    emit(const VaultLoading());
    final result = await initializeVault(NoParams.instance);
    await result.fold(
      (failure) async => emit(VaultError(failure.message)),
      (_) async {
        final filesResult = await getFiles(NoParams.instance);
        filesResult.fold(
          (failure) => emit(VaultError(failure.message)),
          (files) => emit(VaultLoaded(files: files)),
        );
      },
    );
  }

  Future<void> _onLoadFiles(
      VaultLoadFilesEvent event, Emitter<VaultState> emit) async {
    emit(const VaultLoading());
    final result = await getFiles(NoParams.instance);
    result.fold(
      (failure) => emit(VaultError(failure.message)),
      (files) => emit(VaultLoaded(files: files)),
    );
  }

  Future<void> _onImportFile(
      VaultImportFileEvent event, Emitter<VaultState> emit) async {
    emit(const VaultImporting(progress: 0.0));
    final result = await importFile(ImportFileParams(sourcePath: event.sourcePath));
    await result.fold(
      (failure) async => emit(VaultError(failure.message)),
      (_) async {
        emit(const VaultOperationSuccess('File imported successfully'));
        final filesResult = await getFiles(NoParams.instance);
        filesResult.fold(
          (failure) => emit(VaultError(failure.message)),
          (files) => emit(VaultLoaded(files: files)),
        );
      },
    );
  }

  Future<void> _onDeleteFile(
      VaultDeleteFileEvent event, Emitter<VaultState> emit) async {
    final result = await deleteFile(DeleteFileParams(fileId: event.fileId));
    await result.fold(
      (failure) async => emit(VaultError(failure.message)),
      (_) async {
        emit(const VaultOperationSuccess('File deleted successfully'));
        final filesResult = await getFiles(NoParams.instance);
        filesResult.fold(
          (failure) => emit(VaultError(failure.message)),
          (files) {
            final current = state is VaultLoaded ? state as VaultLoaded : null;
            emit(VaultLoaded(
              files: files,
              activeFilter: current?.activeFilter,
              sortOption: current?.sortOption ?? SortOption.dateAddedNewest,
              searchQuery: current?.searchQuery ?? '',
            ));
          },
        );
      },
    );
  }

  Future<void> _onExportFile(
      VaultExportFileEvent event, Emitter<VaultState> emit) async {
    final result = await exportFile(
      ExportFileParams(
        fileId: event.fileId,
        destinationPath: event.destinationPath,
      ),
    );
    result.fold(
      (failure) => emit(VaultError(failure.message)),
      (_) => emit(const VaultOperationSuccess('File exported successfully')),
    );
  }

  Future<void> _onToggleFavorite(
      VaultToggleFavoriteEvent event, Emitter<VaultState> emit) async {
    final result =
        await toggleFavorite(ToggleFavoriteParams(fileId: event.fileId));
    await result.fold(
      (failure) async => emit(VaultError(failure.message)),
      (_) async {
        final filesResult = await getFiles(NoParams.instance);
        filesResult.fold(
          (failure) => emit(VaultError(failure.message)),
          (files) {
            final current = state is VaultLoaded ? state as VaultLoaded : null;
            emit(VaultLoaded(
              files: files,
              activeFilter: current?.activeFilter,
              sortOption: current?.sortOption ?? SortOption.dateAddedNewest,
              searchQuery: current?.searchQuery ?? '',
            ));
          },
        );
      },
    );
  }

  void _onFilterByType(
      VaultFilterByTypeEvent event, Emitter<VaultState> emit) {
    if (state is VaultLoaded) {
      final current = state as VaultLoaded;
      emit(current.copyWith(
        activeFilter: event.type,
        clearFilter: event.type == null,
      ));
    }
  }

  void _onSearch(VaultSearchEvent event, Emitter<VaultState> emit) {
    if (state is VaultLoaded) {
      final current = state as VaultLoaded;
      emit(current.copyWith(searchQuery: event.query));
    }
  }

  void _onSort(VaultSortEvent event, Emitter<VaultState> emit) {
    if (state is VaultLoaded) {
      final current = state as VaultLoaded;
      emit(current.copyWith(sortOption: event.sortOption));
    }
  }
}
