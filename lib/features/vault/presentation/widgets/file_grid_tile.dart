import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/vaulted_file_entity.dart';

class FileGridTile extends StatelessWidget {
  final VaultedFileEntity file;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onFavoriteTap;

  const FileGridTile({
    super.key,
    required this.file,
    required this.onTap,
    this.onLongPress,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildThumbnail(context),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(6),
                child: Text(
                  file.originalName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onFavoriteTap,
                child: Icon(
                  file.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: file.isFavorite ? Colors.red : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    if (file.thumbnailPath != null) {
      return Image.file(
        File(file.thumbnailPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(context),
      );
    }
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          _iconForType(file.type),
          size: 40,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  IconData _iconForType(VaultedFileType type) {
    switch (type) {
      case VaultedFileType.image:
        return Icons.image_outlined;
      case VaultedFileType.video:
        return Icons.videocam_outlined;
      case VaultedFileType.document:
        return Icons.description_outlined;
      case VaultedFileType.other:
        return Icons.insert_drive_file_outlined;
    }
  }
}
