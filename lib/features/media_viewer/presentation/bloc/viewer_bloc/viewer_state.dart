import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../../../vault/domain/entities/vaulted_file_entity.dart';

abstract class ViewerState extends Equatable {
  const ViewerState();

  @override
  List<Object?> get props => [];
}

class ViewerInitial extends ViewerState {
  const ViewerInitial();
}

class ViewerDecrypting extends ViewerState {
  const ViewerDecrypting();
}

class ViewerImageReady extends ViewerState {
  final Uint8List bytes;
  final VaultedFileEntity file;
  const ViewerImageReady({required this.bytes, required this.file});

  @override
  List<Object?> get props => [file.id];
}

class ViewerVideoReady extends ViewerState {
  final String tempPath;
  final VaultedFileEntity file;
  const ViewerVideoReady({required this.tempPath, required this.file});

  @override
  List<Object?> get props => [file.id, tempPath];
}

class ViewerError extends ViewerState {
  final String message;
  const ViewerError(this.message);

  @override
  List<Object?> get props => [message];
}
