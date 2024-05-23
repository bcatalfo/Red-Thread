import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:red_thread/providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends ConsumerState<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                'assets/images/red thread.png',
                height: 40.0,
              ),
            ),
            SizedBox(width: 16.0),
            Text(
              'Red Thread',
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 48,
                color: Color(0xffff5757),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Find love on a blind date',
                  style: theme.textTheme.headlineSmall,
                ),
                Spacer(),
                Text(
                  'By tapping "Create Account" or "Log In", you agree to our [Terms of Service](catalfo tech terms of service link). To view our usage of personal information please view our [privacy policy](catalfo tech privacy policy link).',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                Spacer(),
                SizedBox(
                  height: 16,
                ),
                TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        theme.colorScheme.primaryContainer),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 16.0)),
                    minimumSize: MaterialStateProperty.all(Size(double.infinity,
                        0)), // This makes the button stretch horizontally
                  ),
                  child: Text(
                    'Create Account',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Implement login
                    ref.read(isAuthenticatedProvider.notifier).state = true;
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        theme.colorScheme.primaryContainer),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 16.0)),
                    minimumSize: MaterialStateProperty.all(Size(double.infinity,
                        0)), // This makes the button stretch horizontally
                  ),
                  child: Text(
                    'Login',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 16.0)),
                    minimumSize: MaterialStateProperty.all(Size(double.infinity,
                        0)), // This makes the button stretch horizontally
                  ),
                  child: Text(
                    'Having trouble logging in?',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: theme.colorScheme.onSurface),
                  ),
                ),
                SizedBox(
                  height: 64,
                ),
              ]),
        ),
      ),
    );
  }
}
