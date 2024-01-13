import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:flutter/services.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:red_thread/router.dart';
import 'package:red_thread/presentation/themes.dart';
import 'package:red_thread/jitsi_meet_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await ModelProvider.loadModels();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(ProviderScope(child: BagoolApp()));
}

// TODO: Add auth back
class BagoolApp extends ConsumerWidget {
  BagoolApp({super.key});

  static final jitsiMeet = JitsiMeet();

  static void join() {
    jitsiMeet.join(options);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Red Thread',
      routerConfig: createRouter(ref),
      theme: theme,
    );
  }
}
