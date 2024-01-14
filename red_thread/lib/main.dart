import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:flutter/services.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:red_thread/presentation/pages/preview.dart';
import 'package:red_thread/router.dart';
import 'package:red_thread/presentation/themes.dart';
import 'package:red_thread/jitsi_meet_options.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await ModelProvider.loadModels();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: BagoolApp()));
}

// TODO: Add auth back
class BagoolApp extends ConsumerWidget {
  const BagoolApp({super.key});

  static final jitsiMeet = JitsiMeet();

  static Future<void> join(BuildContext context, WidgetRef ref) async {
    final listener = JitsiMeetEventListener(
      conferenceJoined: (url) {
        debugPrint("conferenceJoined: url: $url");
        ref.read(isJoiningProvider.notifier).state = false;
        context.go('/chat');
      },
      participantJoined: (email, name, role, participantId) {
        debugPrint(
          "participantJoined: email: $email, name: $name, role: $role, "
          "participantId: $participantId",
        );
      },
      chatMessageReceived: (senderId, message, isPrivate, timestamp) {
        debugPrint(
          "chatMessageReceived: senderId: $senderId, message: $message, "
          "isPrivate: $isPrivate timestamp: $timestamp",
        );
      },
      readyToClose: () {
        debugPrint("readyToClose");
      },
    );
    await jitsiMeet.join(options, listener);
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
