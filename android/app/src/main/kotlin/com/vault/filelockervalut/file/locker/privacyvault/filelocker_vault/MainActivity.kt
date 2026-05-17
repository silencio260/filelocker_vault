package com.vault.filelockervalut.file.locker.privacyvault.filelocker_vault

import android.media.MediaScannerConnection
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.filelocker/media"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "deleteMediaByUri" -> {
                        val uriString = call.argument<String>("uri")
                        if (uriString != null) {
                            try {
                                val uri = Uri.parse(uriString)
                                val deleted = contentResolver.delete(uri, null, null)
                                result.success(deleted > 0)
                            } catch (e: Exception) {
                                result.success(false)
                            }
                        } else {
                            result.success(false)
                        }
                    }
                    "scanFile" -> {
                        val path = call.argument<String>("path")
                        if (path != null) {
                            MediaScannerConnection.scanFile(this, arrayOf(path), null) { _, _ ->
                                result.success(true)
                            }
                        } else {
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
