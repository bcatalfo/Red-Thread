import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:red_thread/providers.dart';
import 'package:red_thread/router.dart';
import 'package:red_thread/presentation/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: BagoolApp()));

  await initializeFCM();
}

Future<void> initializeFCM() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permissions for iOS
    await messaging.requestPermission();

    // Get the FCM token and save it to the database
    String? token = await messaging.getToken();
    if (token != null) {
      await saveTokenToDatabase(token);
    }

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
  }
}

Future<void> saveTokenToDatabase(String token) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref('users/${user.uid}');
    await userRef.update({'fcmToken': token});
    debugPrint('FCM Token saved: $token');
  }
}

class BagoolApp extends ConsumerWidget {
  const BagoolApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: This should probably be myThemeProvider.future dont default to light mode when loading
    final themeMode = ref.watch(myThemeProvider).when(
          data: (data) => data,
          error: (_, __) => ThemeMode.light,
          loading: () => ThemeMode.light,
        );

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
