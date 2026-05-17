import 'package:equatable/equatable.dart';

abstract class AlbumEvent extends Equatable {
  const AlbumEvent();

  @override
  List<Object?> get props => [];
}

class AlbumLoadEvent extends AlbumEvent {
  const AlbumLoadEvent();
}

class AlbumCreateEvent extends AlbumEvent {
  final String name;
  const AlbumCreateEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class AlbumDeleteEvent extends AlbumEvent {
  final String albumId;
  const AlbumDeleteEvent(this.albumId);

  @override
  List<Object?> get props => [albumId];
}

class AlbumAddFileEvent extends AlbumEvent {
  final String fileId;
  final String albumId;
  const AlbumAddFileEvent({required this.fileId, required this.albumId});

  @override
  List<Object?> get props => [fileId, albumId];
}

class AlbumRemoveFileEvent extends AlbumEvent {
  final String fileId;
  final String albumId;
  const AlbumRemoveFileEvent({required this.fileId, required this.albumId});

  @override
  List<Object?> get props => [fileId, albumId];
}
