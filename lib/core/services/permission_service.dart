import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<bool> requestPhotoPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  Future<bool> checkStoragePermission() async {
    return await Permission.storage.isGranted;
  }

  Future<bool> checkPhotoPermission() async {
    return await Permission.photos.isGranted;
  }

  Future<bool> openSettings() async {
    return openAppSettings();
  }
}
