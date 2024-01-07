import 'package:flutter/material.dart';
import 'package:red_thread/presentation/drawer_closed.dart';
import 'package:red_thread/presentation/pages/video_preview.dart';
import 'package:red_thread/presentation/themes.dart';
//import 'models/ModelProvider.dart';

void main() async {
  runApp(const BagoolApp());
}

class BagoolApp extends StatelessWidget {
  const BagoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VideoPreview(),
      theme: theme
    );
  }
}