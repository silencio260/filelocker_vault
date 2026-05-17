import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/pin_setup_page.dart';
import '../../features/auth/presentation/pages/unlock_page.dart';
import '../../features/auth/presentation/pages/biometric_setup_page.dart';
import '../../features/vault/presentation/pages/vault_home_page.dart';
import '../../features/vault/presentation/pages/album_detail_page.dart';
import '../../features/vault/domain/entities/album_entity.dart';
import '../../features/media_viewer/presentation/pages/media_viewer_page.dart';
import '../../features/vault/domain/entities/vaulted_file_entity.dart';
import 'app_routes.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.pinSetup:
      return MaterialPageRoute(builder: (_) => const PinSetupPage());

    case AppRoutes.unlock:
      return MaterialPageRoute(builder: (_) => const UnlockPage());

    case AppRoutes.biometricSetup:
      return MaterialPageRoute(builder: (_) => const BiometricSetupPage());

    case AppRoutes.vaultHome:
      return MaterialPageRoute(builder: (_) => const VaultHomePage());

    case AppRoutes.albumDetail:
      final album = settings.arguments as AlbumEntity;
      return MaterialPageRoute(
          builder: (_) => AlbumDetailPage(album: album));

    case AppRoutes.mediaViewer:
      final args = settings.arguments as MediaViewerArgs;
      return MaterialPageRoute(
          builder: (_) => MediaViewerPage(
                files: args.files,
                initialIndex: args.initialIndex,
              ));

    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('No route for ${settings.name}')),
        ),
      );
  }
}

class MediaViewerArgs {
  final List<VaultedFileEntity> files;
  final int initialIndex;

  const MediaViewerArgs({required this.files, required this.initialIndex});
}
