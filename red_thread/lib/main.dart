import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:flutter/services.dart';
import 'package:red_thread/router.dart';
import 'package:red_thread/presentation/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await ModelProvider.loadModels();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: BagoolApp()));
}

class BagoolApp extends ConsumerWidget {
  const BagoolApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Red Thread',
      routerConfig: createRouter(ref),
      theme: theme,
    );
  }
}
