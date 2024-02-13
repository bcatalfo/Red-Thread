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
  List<Rect> rectangles = [];
  Set<Rect> backgroundRectangles = {};

  void calculateRectangles(Size size){
    final width = mask.width;
    final height = mask.height;
    const int pixelSize = 4;
    for (int y = 0; y < height; y += pixelSize) {
      for (int x = 0; x < width; x += pixelSize) {
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
        final double bx = translateX(
          (x + pixelSize).toDouble(),
          size,
          Size(mask.width.toDouble(), mask.height.toDouble()),
          rotation,
          cameraLensDirection,
        );
        final double by = translateY(
          (y + pixelSize).toDouble(),
          size,
          Size(mask.width.toDouble(), mask.height.toDouble()),
          rotation,
          cameraLensDirection,
        );
        rectangles.add(Rect.fromLTRB(tx, ty, bx, by));
      }
    }
  }
  @override
  void paint(Canvas canvas, Size size) {
    if (rectangles.isEmpty){
      calculateRectangles(size);
    }
    final width = mask.width;
    final height = mask.height;
    final confidences = mask.confidences;

    final paint = Paint()..style = PaintingStyle.fill;

    //List<Offset> offsets = [];
    

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int tx = translateX(
          x.toDouble(),
          size,
          Size(mask.width.toDouble(), mask.height.toDouble()),
          rotation,
          cameraLensDirection,
        ).round();
        final int ty = translateY(
          y.toDouble(),
          size,
          Size(mask.width.toDouble(), mask.height.toDouble()),
          rotation,
          cameraLensDirection,
        ).round();

        if (confidences[(y * width) + x] < 0.5) {
          //offsets.add(Offset(tx.toDouble(), ty.toDouble()));
          // TODO: modify this to add the rectangles to a set
          backgroundRectangles.add(Rect.fromLTWH(tx.toDouble(), ty.toDouble(), 2, 2));
        }
      }
    }
    paint.color = color;

    for (var rectangle in backgroundRectangles) {
      canvas.drawRect(rectangle, paint);
    }
  }

  @override
  bool shouldRepaint(SegmentationPainter oldDelegate) {
    return oldDelegate.mask != mask;
  }
}
