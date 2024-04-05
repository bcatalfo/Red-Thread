import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:red_thread/presentation/face_detector_painter.dart';
import 'package:red_thread/utils/coordinates_translator.dart';
import 'detector_view.dart';
import 'package:red_thread/presentation/pages/verification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FaceDetectorView extends StatefulWidget {
  const FaceDetectorView({super.key});

  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: false,
      enableClassification: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _paint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return DetectorView(
          title: 'Selfie Segmenter',
          customPaint: _paint,
          text: _text,
          onImage: (inputImage) => _processImage(inputImage, ref),
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
        );
      },
    );
  }

  Future<void> _processImage(InputImage inputImage, WidgetRef ref) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final faces = await _faceDetector.processImage(inputImage);
    if (!mounted) {
      return;
    }
    ref.read(numberOfFacesDetectedProvider.notifier).state = faces.length;
    // if faces is not empty set smileprobability and isFaceCentered
    bool isFaceCentered = false;
    bool isFaceTooClose = false;
    bool isFaceTooFar = false;
    if (faces.isNotEmpty) {
      ref.read(smileProbabilityProvider.notifier).state =
          faces[0].smilingProbability ?? 0.0;
      final imageSize = inputImage.metadata?.size;
      if (imageSize != null) {
        //final imageCenter = Offset(imageSize.width / 2, imageSize.height / 2);
        final imageCenterX = translateX(imageSize.width / 2, imageSize,
            imageSize, inputImage.metadata!.rotation, _cameraLensDirection);
        final imageCenterY = translateX(imageSize.height / 2, imageSize,
            imageSize, inputImage.metadata!.rotation, _cameraLensDirection);
        final faceCenterX = translateX(
          faces[0].boundingBox.center.dx,
          imageSize,
          imageSize,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        final faceCenterY = translateY(
          faces[0].boundingBox.center.dy,
          imageSize,
          imageSize,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        final faceLeft = translateX(
          faces[0].boundingBox.left,
          imageSize,
          imageSize,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        final faceRight = translateX(
          faces[0].boundingBox.right,
          imageSize,
          imageSize,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        final faceTop = translateY(
          faces[0].boundingBox.top,
          imageSize,
          imageSize,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        final faceBottom = translateY(
          faces[0].boundingBox.bottom,
          imageSize,
          imageSize,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        final faceWidth = faceRight - faceLeft;
        final faceHeight = faceBottom - faceTop;
        final faceCenter = Offset(faceCenterX, faceCenterY);
        isFaceCentered = (faceCenter.dx - imageCenterX).abs() < 50 &&
            (faceCenter.dy - imageCenterY).abs() < 50;
        ref.read(isFaceCenteredProvider.notifier).state = isFaceCentered;
        isFaceTooClose = faceWidth > 200;
        isFaceTooFar = faceWidth < 175;
        ref.read(isFaceTooFarProvider.notifier).state = isFaceTooFar;
        ref.read(isFaceTooCloseProvider.notifier).state = isFaceTooClose;
      }
    }
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final facePainter = FaceDetectorPainter(
        faces,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
        isFaceCentered && !isFaceTooClose && !isFaceTooFar,
      );
      _paint = CustomPaint(painter: facePainter, willChange: true);
    } else {
      String text = 'Faces found: ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;

      _paint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
