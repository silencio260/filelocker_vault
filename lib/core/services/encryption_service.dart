import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';

const int _streamChunkSize = 1024 * 1024;

class EncryptionService {
  final FlutterSecureStorage _storage;

  EncryptionService({required FlutterSecureStorage storage})
      : _storage = storage;

  static const String _masterKeyKey = 'vault_master_key';
  static const int _keySize = 32;
  static const int _ivSize = 16;

  Uint8List? _cachedMasterKey;

  Future<void> initialize() async {
    await _ensureMasterKey();
  }

  Future<Uint8List> _ensureMasterKey() async {
    if (_cachedMasterKey != null) return _cachedMasterKey!;

    try {
      final storedKey = await _storage.read(key: _masterKeyKey);
      if (storedKey != null) {
        _cachedMasterKey = base64Decode(storedKey);
        return _cachedMasterKey!;
      }
    } catch (e) {
      debugPrint('Error reading master key: $e');
    }

    _cachedMasterKey = _generateRandomBytes(_keySize);
    await _storage.write(
        key: _masterKeyKey, value: base64Encode(_cachedMasterKey!));
    return _cachedMasterKey!;
  }

  Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  Uint8List generateIV() => _generateRandomBytes(_ivSize);

  Stream<List<int>> _createChunkedStream(Stream<List<int>> input) {
    return input.transform(_ChunkedStreamTransformer(_streamChunkSize));
  }

  Future<DecryptionResult> decryptFileToMemory(
    String encryptedPath,
    String ivBase64,
  ) async {
    try {
      final encryptedFile = File(encryptedPath);
      if (!await encryptedFile.exists()) {
        return DecryptionResult(
            success: false, error: 'Encrypted file does not exist');
      }

      final raf = await encryptedFile.open();
      final header = await raf.read(8);
      await raf.close();

      final key = await _ensureMasterKey();
      final iv = base64Decode(ivBase64);

      if (header.length >= 4 &&
          header[0] == 0x4C &&
          header[1] == 0x4B &&
          header[2] == 0x52 &&
          header[3] == 0x53) {
        // CTR streamed format
        final ctr = CTRStreamCipher(AESEngine())
          ..init(false, ParametersWithIV<KeyParameter>(KeyParameter(key), iv));

        final inputStream = _createChunkedStream(encryptedFile.openRead(8));
        final decryptedBytes = <int>[];

        await for (final chunk in inputStream) {
          final decrypted = ctr.process(Uint8List.fromList(chunk));
          decryptedBytes.addAll(decrypted);
        }

        return DecryptionResult(
            success: true, data: Uint8List.fromList(decryptedBytes));
      } else if (header.length >= 4 &&
          header[0] == 0x4C &&
          header[1] == 0x4B &&
          header[2] == 0x52 &&
          header[3] == 0x47) {
        // GCM format
        final gcm = GCMBlockCipher(AESEngine())
          ..init(false,
              AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));

        final fileSize = await encryptedFile.length();
        final raf2 = await encryptedFile.open();
        await raf2.read(8);
        final encryptedData = await raf2.read(fileSize - 8);
        await raf2.close();

        final decrypted = gcm.process(Uint8List.fromList(encryptedData));
        return DecryptionResult(success: true, data: decrypted);
      } else {
        return DecryptionResult(
            success: false, error: 'Unknown encrypted file format');
      }
    } catch (e) {
      debugPrint('decryptFileToMemory error: $e');
      return DecryptionResult(success: false, error: 'Decryption failed: $e');
    }
  }

  Future<FileEncryptionResult> encryptFileInIsolate(
    String sourcePath,
    String destinationPath, {
    bool useGcm = true,
    Function(int bytesProcessed, int totalBytes)? onProgress,
  }) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        return FileEncryptionResult(
            success: false, error: 'Source file does not exist');
      }

      final key = await _ensureMasterKey();
      final iv = generateIV();
      final totalBytes = await sourceFile.length();

      final result = await compute(
        _encryptFileIsolate,
        _IsolateEncryptParams(
          sourcePath: sourcePath,
          destinationPath: destinationPath,
          keyBase64: base64Encode(key),
          ivBase64: base64Encode(iv),
          useGcm: useGcm,
        ),
      );

      if (result.success) {
        return FileEncryptionResult(
          success: true,
          encryptedPath: destinationPath,
          iv: base64Encode(iv),
          originalSize: totalBytes,
          encryptedSize: result.encryptedSize,
        );
      } else {
        return FileEncryptionResult(success: false, error: result.error);
      }
    } catch (e) {
      debugPrint('encryptFileInIsolate error: $e');
      return FileEncryptionResult(
          success: false, error: 'Isolate encryption failed: $e');
    }
  }

  Future<FileDecryptionResult> decryptFileInIsolate(
    String encryptedPath,
    String destinationPath,
    String ivBase64, {
    Function(int bytesProcessed, int totalBytes)? onProgress,
  }) async {
    try {
      final encryptedFile = File(encryptedPath);
      if (!await encryptedFile.exists()) {
        return FileDecryptionResult(
            success: false, error: 'Encrypted file does not exist');
      }

      final key = await _ensureMasterKey();

      final result = await compute(
        _decryptFileIsolate,
        _IsolateDecryptParams(
          encryptedPath: encryptedPath,
          destinationPath: destinationPath,
          keyBase64: base64Encode(key),
          ivBase64: ivBase64,
          useGcm: true,
        ),
      );

      if (result.success) {
        return FileDecryptionResult(
          success: true,
          decryptedPath: destinationPath,
          decryptedSize: result.decryptedSize,
        );
      } else {
        return FileDecryptionResult(success: false, error: result.error);
      }
    } catch (e) {
      debugPrint('decryptFileInIsolate error: $e');
      return FileDecryptionResult(
          success: false, error: 'Isolate decryption failed: $e');
    }
  }

  String generateHash(Uint8List data) => sha256.convert(data).toString();

  Future<bool> secureDelete(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return true;

      final length = await file.length();
      final raf = await file.open(mode: FileMode.write);

      try {
        const int chunkSize = 1024 * 1024;
        final randomChunk = _generateRandomBytes(chunkSize);
        final zeroChunk = Uint8List(chunkSize);

        int written = 0;
        await raf.setPosition(0);
        while (written < length) {
          final remaining = length - written;
          final toWrite = remaining < chunkSize ? remaining : chunkSize;
          if (toWrite == chunkSize) {
            await raf.writeFrom(randomChunk);
          } else {
            await raf.writeFrom(randomChunk, 0, toWrite.toInt());
          }
          written += toWrite;
        }

        written = 0;
        await raf.setPosition(0);
        while (written < length) {
          final remaining = length - written;
          final toWrite = remaining < chunkSize ? remaining : chunkSize;
          if (toWrite == chunkSize) {
            await raf.writeFrom(zeroChunk);
          } else {
            await raf.writeFrom(zeroChunk, 0, toWrite.toInt());
          }
          written += toWrite;
        }
      } finally {
        await raf.close();
      }

      await file.delete();
      return true;
    } catch (e) {
      debugPrint('Secure delete error: $e');
      try {
        await File(filePath).delete();
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  Future<bool> hasEncryptionKey() async {
    try {
      final key = await _storage.read(key: _masterKeyKey);
      return key != null;
    } catch (_) {
      return false;
    }
  }
}

// ---------------------------------------------------------------------------
// Isolate helpers — must be top-level for compute()
// ---------------------------------------------------------------------------

class _IsolateEncryptParams {
  final String sourcePath;
  final String destinationPath;
  final String keyBase64;
  final String ivBase64;
  final bool useGcm;

  const _IsolateEncryptParams({
    required this.sourcePath,
    required this.destinationPath,
    required this.keyBase64,
    required this.ivBase64,
    required this.useGcm,
  });
}

class _IsolateDecryptParams {
  final String encryptedPath;
  final String destinationPath;
  final String keyBase64;
  final String ivBase64;
  final bool useGcm;

  const _IsolateDecryptParams({
    required this.encryptedPath,
    required this.destinationPath,
    required this.keyBase64,
    required this.ivBase64,
    required this.useGcm,
  });
}

class _IsolateEncryptResult {
  final bool success;
  final int encryptedSize;
  final String? error;

  const _IsolateEncryptResult({
    required this.success,
    this.encryptedSize = 0,
    this.error,
  });
}

class _IsolateDecryptResult {
  final bool success;
  final int decryptedSize;
  final String? error;

  const _IsolateDecryptResult({
    required this.success,
    this.decryptedSize = 0,
    this.error,
  });
}

Future<_IsolateEncryptResult> _encryptFileIsolate(
    _IsolateEncryptParams params) async {
  try {
    final key = base64Decode(params.keyBase64);
    final iv = base64Decode(params.ivBase64);
    final sourceFile = File(params.sourcePath);
    final destFile = File(params.destinationPath);
    final totalBytes = await sourceFile.length();
    final sink = destFile.openWrite();

    if (params.useGcm) {
      final gcm = GCMBlockCipher(AESEngine())
        ..init(true, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));

      final header = Uint8List(8);
      header[0] = 0x4C;
      header[1] = 0x4B;
      header[2] = 0x52;
      header[3] = 0x47;
      header[4] = (totalBytes & 0xFF);
      header[5] = ((totalBytes >> 8) & 0xFF);
      header[6] = ((totalBytes >> 16) & 0xFF);
      header[7] = ((totalBytes >> 24) & 0xFF);
      sink.add(header);

      // processBytes incrementally — do NOT call process() in a loop because
      // process() calls doFinal() which finalises the cipher after the first chunk.
      await for (final chunk in sourceFile
          .openRead()
          .transform(_ChunkedStreamTransformer(1024 * 1024))) {
        final input = Uint8List.fromList(chunk);
        final output = Uint8List(input.length);
        final written = gcm.processBytes(input, 0, input.length, output, 0);
        if (written > 0) sink.add(output.sublist(0, written));
      }
      // doFinal once at the end — appends the 16-byte GCM auth tag.
      final finalOut = Uint8List(32);
      final finalLen = gcm.doFinal(finalOut, 0);
      if (finalLen > 0) sink.add(finalOut.sublist(0, finalLen));
    } else {
      final ctr = CTRStreamCipher(AESEngine())
        ..init(true, ParametersWithIV<KeyParameter>(KeyParameter(key), iv));

      final header = Uint8List(8);
      header[0] = 0x4C;
      header[1] = 0x4B;
      header[2] = 0x52;
      header[3] = 0x53;
      header[4] = (totalBytes & 0xFF);
      header[5] = ((totalBytes >> 8) & 0xFF);
      header[6] = ((totalBytes >> 16) & 0xFF);
      header[7] = ((totalBytes >> 24) & 0xFF);
      sink.add(header);

      await for (final chunk in sourceFile
          .openRead()
          .transform(_ChunkedStreamTransformer(1024 * 1024))) {
        sink.add(ctr.process(Uint8List.fromList(chunk)));
      }
    }

    await sink.flush();
    await sink.close();

    return _IsolateEncryptResult(
        success: true, encryptedSize: await destFile.length());
  } catch (e) {
    return _IsolateEncryptResult(success: false, error: e.toString());
  }
}

Future<_IsolateDecryptResult> _decryptFileIsolate(
    _IsolateDecryptParams params) async {
  try {
    final key = base64Decode(params.keyBase64);
    final iv = base64Decode(params.ivBase64);
    final encryptedFile = File(params.encryptedPath);
    final destFile = File(params.destinationPath);
    final sink = destFile.openWrite();

    final raf = await encryptedFile.open();
    final header = await raf.read(8);
    await raf.close();

    if (header.length < 8) {
      return _IsolateDecryptResult(
          success: false, error: 'File too short to contain header');
    }

    final originalSize =
        header[4] | (header[5] << 8) | (header[6] << 16) | (header[7] << 24);

    if (header[0] == 0x4C &&
        header[1] == 0x4B &&
        header[2] == 0x52 &&
        header[3] == 0x47) {
      final gcm = GCMBlockCipher(AESEngine())
        ..init(false, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));
      // Same fix: use processBytes per chunk + doFinal once.
      // +16 buffer per chunk because PointyCastle may release previously buffered
      // bytes (it buffers up to macSize bytes internally to isolate the auth tag).
      await for (final chunk in encryptedFile
          .openRead(8)
          .transform(_ChunkedStreamTransformer(1024 * 1024))) {
        final input = Uint8List.fromList(chunk);
        final output = Uint8List(input.length + 16);
        final written = gcm.processBytes(input, 0, input.length, output, 0);
        if (written > 0) sink.add(output.sublist(0, written));
      }
      // doFinal verifies the auth tag and outputs any remaining plaintext bytes.
      final finalSize = gcm.getOutputSize(0);
      final finalOut = Uint8List(finalSize > 0 ? finalSize : 16);
      final finalLen = gcm.doFinal(finalOut, 0);
      if (finalLen > 0) sink.add(finalOut.sublist(0, finalLen));
    } else if (header[0] == 0x4C &&
        header[1] == 0x4B &&
        header[2] == 0x52 &&
        header[3] == 0x53) {
      final ctr = CTRStreamCipher(AESEngine())
        ..init(false, ParametersWithIV<KeyParameter>(KeyParameter(key), iv));
      await for (final chunk in encryptedFile
          .openRead(8)
          .transform(_ChunkedStreamTransformer(1024 * 1024))) {
        sink.add(ctr.process(Uint8List.fromList(chunk)));
      }
    } else {
      await sink.close();
      return _IsolateDecryptResult(
          success: false, error: 'Unknown file format');
    }

    await sink.flush();
    await sink.close();

    return _IsolateDecryptResult(success: true, decryptedSize: originalSize);
  } catch (e) {
    return _IsolateDecryptResult(success: false, error: e.toString());
  }
}

// ---------------------------------------------------------------------------
// Result types
// ---------------------------------------------------------------------------

class EncryptionResult {
  final bool success;
  final Uint8List? data;
  final String? iv;
  final String? error;

  const EncryptionResult(
      {required this.success, this.data, this.iv, this.error});
}

class DecryptionResult {
  final bool success;
  final Uint8List? data;
  final String? error;

  const DecryptionResult(
      {required this.success, this.data, this.error});
}

class FileEncryptionResult {
  final bool success;
  final String? encryptedPath;
  final String? iv;
  final int? originalSize;
  final int? encryptedSize;
  final String? error;

  const FileEncryptionResult({
    required this.success,
    this.encryptedPath,
    this.iv,
    this.originalSize,
    this.encryptedSize,
    this.error,
  });
}

class FileDecryptionResult {
  final bool success;
  final String? decryptedPath;
  final int? decryptedSize;
  final String? error;

  const FileDecryptionResult({
    required this.success,
    this.decryptedPath,
    this.decryptedSize,
    this.error,
  });
}

// ---------------------------------------------------------------------------
// Stream transformer
// ---------------------------------------------------------------------------

class _ChunkedStreamTransformer
    extends StreamTransformerBase<List<int>, List<int>> {
  final int chunkSize;

  _ChunkedStreamTransformer(this.chunkSize);

  @override
  Stream<List<int>> bind(Stream<List<int>> stream) {
    final controller = StreamController<List<int>>();
    final buffer = <int>[];

    stream.listen(
      (data) {
        buffer.addAll(data);
        while (buffer.length >= chunkSize) {
          controller.add(Uint8List.fromList(buffer.sublist(0, chunkSize)));
          buffer.removeRange(0, chunkSize);
        }
      },
      onDone: () {
        if (buffer.isNotEmpty) {
          controller.add(Uint8List.fromList(buffer));
        }
        controller.close();
      },
      onError: controller.addError,
    );

    return controller.stream;
  }
}
