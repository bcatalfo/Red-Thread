import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:flutter/services.dart';
import 'package:red_thread/providers.dart';
import 'package:red_thread/router.dart';
import 'package:red_thread/presentation/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
  final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  if (apnsToken != null) {
    // APNS token is available, make FCM plugin API requests...
  }
  final fcmToken = await FirebaseMessaging.instance.getToken();
  debugPrint("FCM token: $fcmToken");
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: BagoolApp()));
  FlutterNativeSplash.remove();
}

// TODO: Add auth back
class BagoolApp extends ConsumerWidget {
  const BagoolApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(myThemeProvider).when(
        data: (data) => data,
        error: (_, __) => ThemeMode.light,
        loading: () => ThemeMode.light);

    return MaterialApp.router(
      title: 'Red Thread',
      routerConfig: createRouter(ref),
      theme: MaterialTheme.light(),
      darkTheme: MaterialTheme.dark(),
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
