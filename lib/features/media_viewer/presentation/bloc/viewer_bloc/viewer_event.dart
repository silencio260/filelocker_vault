import 'package:equatable/equatable.dart';
import '../../../../vault/domain/entities/vaulted_file_entity.dart';

abstract class ViewerEvent extends Equatable {
  const ViewerEvent();

  @override
  List<Object?> get props => [];
}

class ViewerLoadImageEvent extends ViewerEvent {
  final VaultedFileEntity file;
  const ViewerLoadImageEvent(this.file);

  @override
  List<Object?> get props => [file.id];
}

class ViewerLoadVideoEvent extends ViewerEvent {
  final VaultedFileEntity file;
  const ViewerLoadVideoEvent(this.file);

  @override
  List<Object?> get props => [file.id];
}

class ViewerPageChangedEvent extends ViewerEvent {
  final int index;
  const ViewerPageChangedEvent(this.index);

  @override
  List<Object?> get props => [index];
}
