import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'coordinates_translator.dart';
import 'themes.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
    this.faces,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  final List<Face> faces;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint faceBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = theme.colorScheme.primary
      ..strokeWidth = 3.0;
    final Paint centerBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = theme.colorScheme.secondary
      ..strokeWidth = 3.0;
    final Paint glowPaint = Paint()
      ..color = theme.colorScheme.primary // Choose a glow color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..maskFilter =
          const MaskFilter.blur(BlurStyle.normal, 5); // Outer blur for glow effect

    for (final Face face in faces) {
      final left = translateX(
        face.boundingBox.left,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final top = translateY(
        face.boundingBox.top,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final right = translateX(
        face.boundingBox.right,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final bottom = translateY(
        face.boundingBox.bottom,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );

      // Instead of drawing a full rectangle, draw a path that outlines just the edges
      final Rect rect = Rect.fromLTRB(left, top, right, bottom);
      canvas.drawRect(
        rect,
        faceBorderPaint,
      );

      final Path edgePath = Path()
        ..moveTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top)
        ..lineTo(rect.right, rect.bottom)
        ..lineTo(rect.left, rect.bottom)
        ..close();

      // Make it glow!
      canvas.drawPath(edgePath, glowPaint);

      // draw a rectangle the same size as the face but centered in the frame
      // Define the central box size
      final double boxWidth = right - left + 50; // Example width
      final double boxHeight = bottom - top + 100; // Example height

      // Calculate the position of the box
      final double left2 = (size.width - boxWidth) / 2;
      final double top2 = (size.height - boxHeight) / 2;

      // Draw the box
      canvas.drawRect(
          Rect.fromLTWH(left2, top2, boxWidth, boxHeight), centerBorderPaint);

      void paintContour(FaceContourType type) {
        final contour = face.contours[type];
        if (contour?.points != null) {
          for (final Point point in contour!.points) {
            canvas.drawCircle(
                Offset(
                  translateX(
                    point.x.toDouble(),
                    size,
                    imageSize,
                    rotation,
                    cameraLensDirection,
                  ),
                  translateY(
                    point.y.toDouble(),
                    size,
                    imageSize,
                    rotation,
                    cameraLensDirection,
                  ),
                ),
                1,
                faceBorderPaint);
          }
        }
      }

      void paintLandmark(FaceLandmarkType type) {
        final landmark = face.landmarks[type];
        if (landmark?.position != null) {
          canvas.drawCircle(
              Offset(
                translateX(
                  landmark!.position.x.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
                translateY(
                  landmark.position.y.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
              ),
              2,
              centerBorderPaint);
        }
      }

      for (final type in FaceContourType.values) {
        paintContour(type);
      }

      for (final type in FaceLandmarkType.values) {
        paintLandmark(type);
      }
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;
  }
}
