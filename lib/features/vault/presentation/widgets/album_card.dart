import 'package:flutter/material.dart';
import '../../domain/entities/album_entity.dart';

class AlbumCard extends StatelessWidget {
  final AlbumEntity album;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const AlbumCard({
    super.key,
    required this.album,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _iconForType(album.type),
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      album.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${album.fileCount} ${album.fileCount == 1 ? 'file' : 'files'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              if (!album.isDefault)
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(AlbumType type) {
    switch (type) {
      case AlbumType.favorites:
        return Icons.favorite_outline;
      case AlbumType.recent:
        return Icons.access_time;
      case AlbumType.screenshots:
        return Icons.screenshot;
      case AlbumType.camera:
        return Icons.camera_alt_outlined;
      case AlbumType.downloads:
        return Icons.download_outlined;
      case AlbumType.custom:
        return Icons.folder_outlined;
    }
  }
}
