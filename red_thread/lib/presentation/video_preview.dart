import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class VideoPreview extends StatefulWidget {
  const VideoPreview({super.key});

  @override
  VideoPreviewState createState() => VideoPreviewState();
}

class VideoPreviewState extends State<VideoPreview> {
  CameraController? _controller;
  Uint8List? processedFrame;
  CameraDescription? _frontCamera;
  int frameWidth = 0;
  int frameHeight = 0;
  bool isProcessing = false;

  final segmenter = SelfieSegmenter(
    mode: SegmenterMode.stream,
    enableRawSizeMask: true,
  );
  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void initState() {
    super.initState();
    // Initialize camera and start frame capture
    // For each frame, apply segmentation and custom background, then update UI
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    final camera = await availableCameras();
    _frontCamera = camera.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
    _controller = CameraController(_frontCamera!, ResolutionPreset.low);
    _controller!.initialize().then((_) {
      frameWidth = _controller!.value.previewSize!.width as int;
      frameHeight = _controller!.value.previewSize!.height as int;
      // Ensure that plugin services are initialized so that `startImageStream` can be called
      if (!mounted) {
        return;
      }
      setState(() {
        // Update the state to indicate that the camera is initialized
        _controller?.startImageStream((image) {
          debugPrint(image.format.group.toString()); //its bgra8888
          // Process the frame and update the UI
          updateFrame(image);
        });
      });
    });
  }

  void updateFrame(CameraImage image) async {
    if (isProcessing) {
      return;
    }
    isProcessing = true;
    // Convert image to an InputImage so we can apply machine learning
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      debugPrint('null input image loser');
      return;
    }
    /* final mask = await segmenter.processImage(inputImage);
    if (mask == null) {
      debugPrint('null mask loser');
      return;
    } */
    // Assuming BGRA8888 format for iOS, directly use the bytes from the first plane
    final Uint8List frameBytes = image.planes.first.bytes;
    final int imageWidth = image.width;
    final int imageHeight = image.height;
    setState(() {
      debugPrint('setting state');
      processedFrame = frameBytes;
      frameWidth = imageWidth;
      frameHeight = imageHeight;
      isProcessing = false;
    });
  }


  InputImage? _inputImageFromCameraImage(CameraImage image) {
    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas
    final camera = _frontCamera!;
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller?.dispose();
    // Dispose of the segmenter
    segmenter.close();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Container(
    child: processedFrame != null
        ? RawImageWidget(
            rawImageData: processedFrame!,
            width: frameWidth,  // Make sure these are defined and updated in your state
            height: frameHeight,
          )
        : const Placeholder(),
  );
}
}

class RawImageWidget extends StatelessWidget {
  final Uint8List rawImageData;
  final int width;
  final int height;

  const RawImageWidget({
    Key? key,
    required this.rawImageData,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: _processRawImageData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return CustomPaint(
            painter: _ImagePainter(snapshot.data!),
          );
        } else {
          return Container(); // Or some placeholder
        }
      },
    );
  }

  Future<ui.Image> _processRawImageData() async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromPixels(
      rawImageData.buffer.asUint8List(),
      width,
      height,
      ui.PixelFormat.bgra8888,
      (image) {
        completer.complete(image);
      },
    );
    return completer.future;
  }
}

class _ImagePainter extends CustomPainter {
  final ui.Image image;

  _ImagePainter(this.image);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}