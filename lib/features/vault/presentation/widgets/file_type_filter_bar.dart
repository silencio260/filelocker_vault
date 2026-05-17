import 'package:flutter/material.dart';
import '../../domain/entities/vaulted_file_entity.dart';

class FileTypeFilterBar extends StatelessWidget {
  final VaultedFileType? activeFilter;
  final ValueChanged<VaultedFileType?> onFilterChanged;

  const FileTypeFilterBar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            icon: Icons.grid_view,
            isSelected: activeFilter == null,
            onTap: () => onFilterChanged(null),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Images',
            icon: Icons.image_outlined,
            isSelected: activeFilter == VaultedFileType.image,
            onTap: () => onFilterChanged(VaultedFileType.image),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Videos',
            icon: Icons.videocam_outlined,
            isSelected: activeFilter == VaultedFileType.video,
            onTap: () => onFilterChanged(VaultedFileType.video),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Documents',
            icon: Icons.description_outlined,
            isSelected: activeFilter == VaultedFileType.document,
            onTap: () => onFilterChanged(VaultedFileType.document),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
