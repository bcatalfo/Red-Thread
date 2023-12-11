import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mesibo_flutter_sdk/mesibo.dart';
import 'package:red_thread/amplifyconfiguration.dart';
import 'package:red_thread/mesiboPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(const MainApp());
}

Future<void> _configureAmplify() async {
  try {
    // Add Amplify Plugins
    final amplifyAuthCognito = AmplifyAuthCognito();
    await Amplify.addPlugins([amplifyAuthCognito]);

    await Amplify.configure(amplifyconfig);
  } catch (e) {
    print(e);
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Authenticator(
        child: MaterialApp(
      builder: Authenticator.builder(),
      home: FirstMesiboApp(),
      theme: ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
          backgroundColor: Colors.white,
        ),
      ).copyWith(
        indicatorColor: Colors.red,
      ),
      // set the dark theme (optional)
      darkTheme: ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
          backgroundColor: Colors.black,
          brightness: Brightness.dark,
        ),
      ),
      // set the theme mode to respond to the user's system preferences (optional)
      themeMode: ThemeMode.system,
    ));
  }
}
