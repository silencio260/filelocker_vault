import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/decrypt_file_to_memory_usecase.dart';
import '../../../domain/usecases/get_decrypted_temp_path_usecase.dart';
import 'viewer_event.dart';
import 'viewer_state.dart';

class ViewerBloc extends Bloc<ViewerEvent, ViewerState> {
  final DecryptFileToMemoryUseCase decryptToMemory;
  final GetDecryptedTempPathUseCase decryptToTemp;

  String? _currentTempPath;

  ViewerBloc({
    required this.decryptToMemory,
    required this.decryptToTemp,
  }) : super(const ViewerInitial()) {
    on<ViewerLoadImageEvent>(_onLoadImage);
    on<ViewerLoadVideoEvent>(_onLoadVideo);
    on<ViewerPageChangedEvent>(_onPageChanged);
  }

  Future<void> _onLoadImage(
      ViewerLoadImageEvent event, Emitter<ViewerState> emit) async {
    emit(const ViewerDecrypting());
    final file = event.file;

    if (!file.isEncrypted || file.encryptionIv == null) {
      final rawFile = File(file.vaultPath);
      if (await rawFile.exists()) {
        final bytes = await rawFile.readAsBytes();
        emit(ViewerImageReady(bytes: bytes, file: file));
      } else {
        emit(const ViewerError('File not found'));
      }
      return;
    }

    final result = await decryptToMemory(
      DecryptFileParams(encryptedPath: file.vaultPath, iv: file.encryptionIv!),
    );

    result.fold(
      (failure) => emit(ViewerError(failure.message)),
      (bytes) => emit(ViewerImageReady(bytes: bytes, file: file)),
    );
  }

  Future<void> _onLoadVideo(
      ViewerLoadVideoEvent event, Emitter<ViewerState> emit) async {
    emit(const ViewerDecrypting());
    final file = event.file;

    if (!file.isEncrypted || file.encryptionIv == null) {
      emit(ViewerVideoReady(tempPath: file.vaultPath, file: file));
      return;
    }

    final result = await decryptToTemp(
      DecryptToTempParams(
        encryptedPath: file.vaultPath,
        iv: file.encryptionIv!,
        fileName: file.originalName,
      ),
    );

    result.fold(
      (failure) => emit(ViewerError(failure.message)),
      (tempPath) {
        _currentTempPath = tempPath;
        emit(ViewerVideoReady(tempPath: tempPath, file: file));
      },
    );
  }

  void _onPageChanged(ViewerPageChangedEvent event, Emitter<ViewerState> emit) {
    emit(const ViewerInitial());
  }

  @override
  Future<void> close() async {
    if (_currentTempPath != null) {
      final tempFile = File(_currentTempPath!);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
    return super.close();
  }
}
