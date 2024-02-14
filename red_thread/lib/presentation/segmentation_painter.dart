import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:red_thread/presentation/theme.dart';

import 'package:red_thread/utils/coordinates_translator.dart';

class SegmentationPainter extends CustomPainter {
  SegmentationPainter(
    this.mask,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  final SegmentationMask mask;
  final Size imageSize;
  final Color color = globalLightScheme.surfaceVariant;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final width = mask.width;
    final height = mask.height;
    final confidences = mask.confidences;
    final paint = Paint()..style = PaintingStyle.fill
    ..color = color;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final double tx = translateX(
          x.toDouble(),
          size,
          Size(mask.width.toDouble(), mask.height.toDouble()),
          rotation,
          cameraLensDirection,
        );
        final double ty = translateY(
          y.toDouble(),
          size,
          Size(mask.width.toDouble(), mask.height.toDouble()),
          rotation,
          cameraLensDirection,
        );

        if (confidences[(y * width) + x] < 0.5) {
          canvas.drawRect(Rect.fromLTWH(tx, ty, 2, 2), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(SegmentationPainter oldDelegate) {
    return oldDelegate.mask != mask ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.rotation != rotation ||
        oldDelegate.cameraLensDirection != cameraLensDirection;
  }
}
