import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/routes/app_routes.dart';
import '../../domain/entities/vaulted_file_entity.dart';
import '../bloc/album_bloc/album_bloc.dart';
import '../bloc/album_bloc/album_event.dart';
import '../bloc/album_bloc/album_state.dart';
import '../bloc/vault_bloc/vault_bloc.dart';
import '../bloc/vault_bloc/vault_event.dart';
import '../bloc/vault_bloc/vault_state.dart';
import '../widgets/album_card.dart';
import '../widgets/file_grid_tile.dart';
import '../widgets/file_type_filter_bar.dart';
import '../widgets/import_progress_indicator.dart';

class VaultHomePage extends StatelessWidget {
  const VaultHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GetIt.I<VaultBloc>()..add(const VaultInitializeEvent()),
        ),
        BlocProvider(
          create: (_) => GetIt.I<AlbumBloc>()..add(const AlbumLoadEvent()),
        ),
      ],
      child: const _VaultHomeView(),
    );
  }
}

class _VaultHomeView extends StatelessWidget {
  const _VaultHomeView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FileLocker'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearch(context),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All Files'),
              Tab(text: 'Albums'),
              Tab(text: 'Favorites'),
            ],
          ),
        ),
        body: BlocListener<VaultBloc, VaultState>(
          listener: (context, state) {
            if (state is VaultError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is VaultOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: TabBarView(
            children: [
              _AllFilesTab(),
              _AlbumsTab(),
              _FavoritesTab(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _importFile(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _VaultSearchDelegate(
        onSearch: (query) =>
            context.read<VaultBloc>().add(VaultSearchEvent(query)),
      ),
    );
  }

  Future<void> _importFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;

    if (context.mounted) {
      context.read<VaultBloc>().add(VaultImportFileEvent(path));
    }
  }
}

class _AllFilesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VaultBloc, VaultState>(
      builder: (context, state) {
        if (state is VaultLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is VaultImporting) {
          return ImportProgressIndicator(progress: state.progress);
        }
        if (state is VaultLoaded) {
          return Column(
            children: [
              FileTypeFilterBar(
                activeFilter: state.activeFilter,
                onFilterChanged: (type) => context
                    .read<VaultBloc>()
                    .add(VaultFilterByTypeEvent(type)),
              ),
              Expanded(
                child: state.displayFiles.isEmpty
                    ? _EmptyState(
                        message: state.activeFilter != null
                            ? 'No ${state.activeFilter!.displayName.toLowerCase()}s found'
                            : 'No files yet. Tap + to import.',
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: state.displayFiles.length,
                        itemBuilder: (context, index) {
                          final file = state.displayFiles[index];
                          return FileGridTile(
                            file: file,
                            onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.mediaViewer,
                              arguments: {
                                'files': state.displayFiles,
                                'initialIndex': index,
                              },
                            ),
                            onFavoriteTap: () => context
                                .read<VaultBloc>()
                                .add(VaultToggleFavoriteEvent(file.id)),
                            onLongPress: () =>
                                _showFileOptions(context, file),
                          );
                        },
                      ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showFileOptions(BuildContext context, VaultedFileEntity file) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                context
                    .read<VaultBloc>()
                    .add(VaultDeleteFileEvent(file.id));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlbumBloc, AlbumState>(
      builder: (context, state) {
        if (state is AlbumLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AlbumLoaded) {
          if (state.albums.isEmpty) {
            return const _EmptyState(message: 'No albums yet.');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.albums.length,
            itemBuilder: (context, index) {
              final album = state.albums[index];
              return AlbumCard(
                album: album,
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.albumDetail,
                  arguments: album,
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VaultBloc, VaultState>(
      builder: (context, state) {
        if (state is VaultLoaded) {
          final favorites = state.files.where((f) => f.isFavorite).toList();
          if (favorites.isEmpty) {
            return const _EmptyState(message: 'No favorites yet.');
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final file = favorites[index];
              return FileGridTile(
                file: file,
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.mediaViewer,
                  arguments: {'files': favorites, 'initialIndex': index},
                ),
                onFavoriteTap: () => context
                    .read<VaultBloc>()
                    .add(VaultToggleFavoriteEvent(file.id)),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _VaultSearchDelegate extends SearchDelegate<String> {
  final ValueChanged<String> onSearch;

  _VaultSearchDelegate({required this.onSearch});

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            onSearch('');
          },
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          close(context, '');
          onSearch('');
        },
      );

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    close(context, query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) => const SizedBox.shrink();
}
