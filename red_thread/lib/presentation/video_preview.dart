import 'dart:typed_data';
import 'package:flutter/material.dart';

class VideoPreview extends StatefulWidget {
  const VideoPreview({super.key});

  @override
  VideoPreviewState createState() => VideoPreviewState();
}

class VideoPreviewState extends State<VideoPreview> {
  Uint8List? processedFrame;

  @override
  void initState() {
    super.initState();
    // Initialize camera and start frame capture
    // For each frame, apply segmentation and custom background, then update UI
  }

  void updateFrame(Uint8List newFrame) {
    setState(() {
      processedFrame = newFrame;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Display the processed frame, or a placeholder if null
      child: processedFrame != null ? Image.memory(processedFrame!) : const Placeholder(),
    );
  }
}
