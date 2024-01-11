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
    this.isFaceCentered,
  );

  final List<Face> faces;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final bool isFaceCentered;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint centerBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = isFaceCentered ? Colors.green : Colors.red
      ..strokeWidth = 3.0;
    final Paint glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = isFaceCentered ? Colors.green : Colors.red
      ..strokeWidth = 10.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5); // Glow effect

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
      // draw a rectangle the same size as the face but centered in the frame
      // Define the central box size
      const double boxWidth = 240; // Example width
      const double boxHeight = 320; // Example height

      // Calculate the position of the box
      final double left2 = (size.width - boxWidth) / 2;
      final double top2 = (size.height - boxHeight) / 2;

      // Draw the oval
      canvas.drawOval(
        Rect.fromLTWH(left2, top2, boxWidth, boxHeight), centerBorderPaint);

      // Make it glow
      canvas.drawOval(
          Rect.fromLTWH(left2, top2, boxWidth, boxHeight), glowPaint);

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
                centerBorderPaint);
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
