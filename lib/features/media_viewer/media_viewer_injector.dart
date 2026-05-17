import 'package:get_it/get_it.dart';
import '../../core/services/encryption_service.dart';
import 'domain/usecases/decrypt_file_to_memory_usecase.dart';
import 'domain/usecases/get_decrypted_temp_path_usecase.dart';
import 'presentation/bloc/viewer_bloc/viewer_bloc.dart';

final sl = GetIt.instance;

void initMediaViewerDependencies() {
  sl.registerFactory(
    () => DecryptFileToMemoryUseCase(encryptionService: sl<EncryptionService>()),
  );
  sl.registerFactory(
    () => GetDecryptedTempPathUseCase(encryptionService: sl<EncryptionService>()),
  );
  sl.registerFactory(
    () => ViewerBloc(
      decryptToMemory: sl(),
      decryptToTemp: sl(),
    ),
  );
}
