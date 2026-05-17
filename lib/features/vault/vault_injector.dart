import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../core/services/encryption_service.dart';
import 'data/datasources/vault_base_local_data_source.dart';
import 'data/datasources/vault_local_data_source.dart';
import 'data/repositories/vault_repo.dart';
import 'domain/repositories/vault_base_repo.dart';
import 'domain/usecases/add_file_to_album_usecase.dart';
import 'domain/usecases/create_album_usecase.dart';
import 'domain/usecases/delete_album_usecase.dart';
import 'domain/usecases/delete_file_usecase.dart';
import 'domain/usecases/export_file_usecase.dart';
import 'domain/usecases/get_albums_usecase.dart';
import 'domain/usecases/get_files_for_album_usecase.dart';
import 'domain/usecases/get_files_usecase.dart';
import 'domain/usecases/import_file_usecase.dart';
import 'domain/usecases/initialize_vault_usecase.dart';
import 'domain/usecases/remove_file_from_album_usecase.dart';
import 'domain/usecases/toggle_favorite_usecase.dart';
import 'presentation/bloc/album_bloc/album_bloc.dart';
import 'presentation/bloc/vault_bloc/vault_bloc.dart';

final sl = GetIt.instance;

void initVaultDependencies() {
  sl.registerLazySingleton<VaultBaseLocalDataSource>(
    () => VaultLocalDataSource(
      storage: sl<FlutterSecureStorage>(),
      encryptionService: sl<EncryptionService>(),
    ),
  );

  sl.registerLazySingleton<VaultBaseRepo>(
    () => VaultRepo(dataSource: sl()),
  );

  sl.registerFactory(() => InitializeVaultUseCase(repo: sl()));
  sl.registerFactory(() => GetFilesUseCase(repo: sl()));
  sl.registerFactory(() => ImportFileUseCase(repo: sl()));
  sl.registerFactory(() => DeleteFileUseCase(repo: sl()));
  sl.registerFactory(() => ExportFileUseCase(repo: sl()));
  sl.registerFactory(() => ToggleFavoriteUseCase(repo: sl()));
  sl.registerFactory(() => GetAlbumsUseCase(repo: sl()));
  sl.registerFactory(() => CreateAlbumUseCase(repo: sl()));
  sl.registerFactory(() => DeleteAlbumUseCase(repo: sl()));
  sl.registerFactory(() => AddFileToAlbumUseCase(repo: sl()));
  sl.registerFactory(() => RemoveFileFromAlbumUseCase(repo: sl()));
  sl.registerFactory(() => GetFilesForAlbumUseCase(repo: sl()));

  sl.registerFactory(() => VaultBloc(
        initializeVault: sl(),
        getFiles: sl(),
        importFile: sl(),
        deleteFile: sl(),
        exportFile: sl(),
        toggleFavorite: sl(),
      ));

  sl.registerFactory(() => AlbumBloc(
        getAlbums: sl(),
        createAlbum: sl(),
        deleteAlbum: sl(),
        addFileToAlbum: sl(),
        removeFileFromAlbum: sl(),
      ));
}
