import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageViewerWidget extends StatefulWidget {
  final Uint8List bytes;

  const ImageViewerWidget({super.key, required this.bytes});

  @override
  State<ImageViewerWidget> createState() => _ImageViewerWidgetState();
}

class _ImageViewerWidgetState extends State<ImageViewerWidget> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _onDoubleTap(TapDownDetails details) {
    final position = details.localPosition;
    final scale = _transformationController.value.getMaxScaleOnAxis();

    if (scale > 1.0) {
      _transformationController.value = Matrix4.identity();
    } else {
      const zoomScale = 2.5;
      final x = -position.dx * (zoomScale - 1);
      final y = -position.dy * (zoomScale - 1);
      final translation = Matrix4.translationValues(x, y, 0.0);
      final scale = Matrix4.diagonal3Values(zoomScale, zoomScale, 1.0);
      _transformationController.value = translation * scale;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _onDoubleTap,
      onDoubleTap: () {},
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.5,
        maxScale: 5.0,
        child: Image.memory(
          widget.bytes,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image_outlined, size: 64),
          ),
        ),
      ),
    );
  }
}
