import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../services/encryption_service.dart';
import '../services/permission_service.dart';

final sl = GetIt.instance;

Future<void> initCoreDependencies() async {
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  );

  sl.registerLazySingleton<EncryptionService>(
    () => EncryptionService(storage: sl()),
  );

  sl.registerLazySingleton<PermissionService>(() => PermissionService());
}
