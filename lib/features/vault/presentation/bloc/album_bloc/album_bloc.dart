import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/usecase/base_usecase.dart';
import '../../../domain/usecases/add_file_to_album_usecase.dart';
import '../../../domain/usecases/create_album_usecase.dart';
import '../../../domain/usecases/delete_album_usecase.dart';
import '../../../domain/usecases/get_albums_usecase.dart';
import '../../../domain/usecases/remove_file_from_album_usecase.dart';
import 'album_event.dart';
import 'album_state.dart';

class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  final GetAlbumsUseCase getAlbums;
  final CreateAlbumUseCase createAlbum;
  final DeleteAlbumUseCase deleteAlbum;
  final AddFileToAlbumUseCase addFileToAlbum;
  final RemoveFileFromAlbumUseCase removeFileFromAlbum;

  AlbumBloc({
    required this.getAlbums,
    required this.createAlbum,
    required this.deleteAlbum,
    required this.addFileToAlbum,
    required this.removeFileFromAlbum,
  }) : super(const AlbumInitial()) {
    on<AlbumLoadEvent>(_onLoad);
    on<AlbumCreateEvent>(_onCreate);
    on<AlbumDeleteEvent>(_onDelete);
    on<AlbumAddFileEvent>(_onAddFile);
    on<AlbumRemoveFileEvent>(_onRemoveFile);
  }

  Future<void> _onLoad(AlbumLoadEvent event, Emitter<AlbumState> emit) async {
    emit(const AlbumLoading());
    final result = await getAlbums(NoParams.instance);
    result.fold(
      (failure) => emit(AlbumError(failure.message)),
      (albums) => emit(AlbumLoaded(albums)),
    );
  }

  Future<void> _onCreate(
      AlbumCreateEvent event, Emitter<AlbumState> emit) async {
    final result = await createAlbum(CreateAlbumParams(name: event.name));
    await result.fold(
      (failure) async => emit(AlbumError(failure.message)),
      (_) async {
        final albumsResult = await getAlbums(NoParams.instance);
        albumsResult.fold(
          (failure) => emit(AlbumError(failure.message)),
          (albums) => emit(AlbumLoaded(albums)),
        );
      },
    );
  }

  Future<void> _onDelete(
      AlbumDeleteEvent event, Emitter<AlbumState> emit) async {
    final result =
        await deleteAlbum(DeleteAlbumParams(albumId: event.albumId));
    await result.fold(
      (failure) async => emit(AlbumError(failure.message)),
      (_) async {
        final albumsResult = await getAlbums(NoParams.instance);
        albumsResult.fold(
          (failure) => emit(AlbumError(failure.message)),
          (albums) => emit(AlbumLoaded(albums)),
        );
      },
    );
  }

  Future<void> _onAddFile(
      AlbumAddFileEvent event, Emitter<AlbumState> emit) async {
    final result = await addFileToAlbum(
      AddFileToAlbumParams(fileId: event.fileId, albumId: event.albumId),
    );
    await result.fold(
      (failure) async => emit(AlbumError(failure.message)),
      (_) async {
        final albumsResult = await getAlbums(NoParams.instance);
        albumsResult.fold(
          (failure) => emit(AlbumError(failure.message)),
          (albums) => emit(AlbumLoaded(albums)),
        );
      },
    );
  }

  Future<void> _onRemoveFile(
      AlbumRemoveFileEvent event, Emitter<AlbumState> emit) async {
    final result = await removeFileFromAlbum(
      RemoveFileFromAlbumParams(fileId: event.fileId, albumId: event.albumId),
    );
    await result.fold(
      (failure) async => emit(AlbumError(failure.message)),
      (_) async {
        final albumsResult = await getAlbums(NoParams.instance);
        albumsResult.fold(
          (failure) => emit(AlbumError(failure.message)),
          (albums) => emit(AlbumLoaded(albums)),
        );
      },
    );
  }
}
