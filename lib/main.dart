import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/di/container_injector.dart';
import 'features/auth/auth_injector.dart';
import 'features/media_viewer/media_viewer_injector.dart';
import 'features/vault/vault_injector.dart';
import 'my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await initCoreDependencies();
  initAuthDependencies();
  initVaultDependencies();
  initMediaViewerDependencies();

  runApp(const FileLockerApp());
}
