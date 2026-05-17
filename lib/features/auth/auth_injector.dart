import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/auth_base_local_data_source.dart';
import 'data/datasources/auth_local_data_source.dart';
import 'data/repositories/auth_repo.dart';
import 'domain/repositories/auth_base_repo.dart';
import 'domain/usecases/authenticate_biometric_usecase.dart';
import 'domain/usecases/change_pin_usecase.dart';
import 'domain/usecases/check_first_time_usecase.dart';
import 'domain/usecases/enable_biometric_usecase.dart';
import 'domain/usecases/get_auth_state_usecase.dart';
import 'domain/usecases/register_failed_attempt_usecase.dart';
import 'domain/usecases/setup_pin_usecase.dart';
import 'domain/usecases/verify_pin_usecase.dart';
import 'presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

void initAuthDependencies() {
  sl.registerLazySingleton<AuthBaseLocalDataSource>(
    () => AuthLocalDataSource(storage: sl<FlutterSecureStorage>()),
  );

  sl.registerLazySingleton<AuthBaseRepo>(
    () => AuthRepo(dataSource: sl()),
  );

  sl.registerFactory(() => CheckFirstTimeUseCase(repo: sl()));
  sl.registerFactory(() => SetupPinUseCase(repo: sl()));
  sl.registerFactory(() => VerifyPinUseCase(repo: sl()));
  sl.registerFactory(() => AuthenticateBiometricUseCase(repo: sl()));
  sl.registerFactory(() => EnableBiometricUseCase(repo: sl()));
  sl.registerFactory(() => GetAuthStateUseCase(repo: sl()));
  sl.registerFactory(() => RegisterFailedAttemptUseCase(repo: sl()));
  sl.registerFactory(() => ChangePinUseCase(repo: sl()));

  sl.registerFactory(() => AuthBloc(
        checkFirstTime: sl(),
        setupPin: sl(),
        verifyPin: sl(),
        authenticateBiometric: sl(),
        enableBiometric: sl(),
        getAuthState: sl(),
        registerFailedAttempt: sl(),
      ));
}
