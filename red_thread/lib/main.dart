import 'package:flutter/material.dart';
import 'package:red_thread/presentation/pages/video_preview.dart';
import 'package:red_thread/presentation/themes.dart';
//import 'models/ModelProvider.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";

void main() async {
  runApp(const ProviderScope(child: BagoolApp()));
}

class BagoolApp extends ConsumerWidget {
  const BagoolApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: VideoPreview(),
      theme: theme
    );
  }
}