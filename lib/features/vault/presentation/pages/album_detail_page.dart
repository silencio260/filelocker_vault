import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/routes/app_routes.dart';
import '../../domain/entities/album_entity.dart';
import '../bloc/vault_bloc/vault_bloc.dart';
import '../bloc/vault_bloc/vault_event.dart';
import '../bloc/vault_bloc/vault_state.dart';
import '../widgets/file_grid_tile.dart';

class AlbumDetailPage extends StatelessWidget {
  final AlbumEntity album;

  const AlbumDetailPage({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<VaultBloc>()..add(const VaultLoadFilesEvent()),
      child: _AlbumDetailView(album: album),
    );
  }
}

class _AlbumDetailView extends StatelessWidget {
  final AlbumEntity album;

  const _AlbumDetailView({required this.album});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(album.name),
        actions: [
          Text(
            '${album.fileCount} files',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<VaultBloc, VaultState>(
        builder: (context, state) {
          if (state is VaultLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VaultLoaded) {
            final albumFiles =
                state.files.where((f) => album.fileIds.contains(f.id)).toList();

            if (albumFiles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No files in this album',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: albumFiles.length,
              itemBuilder: (context, index) {
                final file = albumFiles[index];
                return FileGridTile(
                  file: file,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.mediaViewer,
                    arguments: {'files': albumFiles, 'initialIndex': index},
                  ),
                  onFavoriteTap: () => context
                      .read<VaultBloc>()
                      .add(VaultToggleFavoriteEvent(file.id)),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
