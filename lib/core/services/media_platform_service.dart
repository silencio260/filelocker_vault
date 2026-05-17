import 'dart:io';
import 'package:flutter/services.dart';

class MediaPlatformService {
  static const _channel = MethodChannel('com.filelocker/media');

  /// Deletes a media file from the Android MediaStore using the content URI
  /// returned by file_picker as [identifier]. Returns true if deleted.
  Future<bool> deleteMediaByUri(String uri) async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('deleteMediaByUri', {'uri': uri}) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Notifies the Android MediaStore to rescan [path]. After a file is deleted
  /// from the filesystem, scanning it removes the stale MediaStore entry so the
  /// gallery no longer shows it.
  Future<void> scanFile(String path) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('scanFile', {'path': path});
    } catch (_) {}
  }
}
