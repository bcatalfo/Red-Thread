import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:red_thread/utils/coordinates_translator.dart';
import 'package:red_thread/presentation/segmentation_painter.dart';
import 'detector_view.dart';
import 'face_detector_painter.dart';
import 'package:red_thread/presentation/pages/preview.dart';
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
  final _segmenter = SelfieSegmenter(
    mode: SegmenterMode.stream,
    enableRawSizeMask: true,
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _faceDetectorPaint;
  CustomPaint? _segmenterPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    _segmenter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        /* return DetectorView(
          title: 'Face Detector',
          customPaint: _faceDetectorPaint,
          text: _text,
          onImage: (inputImage) => _processImage(inputImage, ref),
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
        ); */
        return DetectorView(
      title: 'Selfie Segmenter',
      customPaint: _segmenterPaint,
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
    final mask = await _segmenter.processImage(inputImage);
    if (!mounted) {
      return;
    }
    ref.read(numberOfFacesDetectedProvider.notifier).state = faces.length;
    // if faces is not empty set smileprobability and isFaceCentered
    bool isFaceCentered = false;
    if (faces.isNotEmpty) {
      ref.read(smileProbabilityProvider.notifier).state =
          faces[0].smilingProbability ?? 0.0;
      final imageSize = inputImage.metadata?.size;
      if (imageSize != null) {
        final imageCenter = Offset(imageSize.width / 2, imageSize.height / 2);
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
        final faceCenter = Offset(faceCenterX, faceCenterY);
        isFaceCentered = (faceCenter.dx - imageCenter.dx).abs() < 50 &&
            (faceCenter.dy - imageCenter.dy).abs() < 100;
        ref.read(isFaceCenteredProvider.notifier).state = isFaceCentered;
      }
    }
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null && mask != null) {
      final painter = FaceDetectorPainter(
        faces,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
        isFaceCentered,
      );
      _faceDetectorPaint = CustomPaint(painter: painter);
      final segmenterPainter = SegmentationPainter(
        mask,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _segmenterPaint = CustomPaint(painter: segmenterPainter);
    } else {
      String text = 'Faces found: ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
      _faceDetectorPaint = null;
      _segmenterPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}

