import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:red_thread/providers.dart";
import "package:url_launcher/url_launcher.dart";

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends ConsumerState<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: Image.asset(
                'assets/images/red thread.png',
                height: 24.0,
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              'Red Thread',
              style: theme.textTheme.displayLarge?.copyWith(
                color: const Color(0xffff5757),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const SizedBox(
              height: 48,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Find love on a blind date',
                style: theme.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyLarge,
                text: 'By logging in you agree to our ',
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(color: theme.colorScheme.primary),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final url = Uri.parse(
                            'https://catalfotechnologies.com/terms.html');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                  ),
                  const TextSpan(
                    text:
                        '. To view our usage of personal information please view our ',
                  ),
                  TextSpan(
                    text: 'privacy policy',
                    style: TextStyle(
                        color: theme.colorScheme
                            .primary), // Change to your desired link color
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final url = Uri.parse(
                            'https://catalfotechnologies.com/privacy.html');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                  ),
                  const TextSpan(
                    text: '.',
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 32,
            ),
            TextButton(
              onPressed: () {
                // TODO: Apple sign in
                ref.read(isAuthenticatedProvider.notifier).state = true;
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    theme.colorScheme.primaryContainer),
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 8.0)),
                minimumSize: MaterialStateProperty.all(const Size(double.infinity,
                    0)), // This makes the button stretch horizontally
              ),
              child: Text(
                'Login with Apple',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextButton(
              onPressed: () {
                // TODO: Google sign in
                ref.read(isAuthenticatedProvider.notifier).state = true;
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    theme.colorScheme.primaryContainer),
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 8.0)),
                minimumSize: MaterialStateProperty.all(const Size(double.infinity,
                    0)), // This makes the button stretch horizontally
              ),
              child: Text(
                'Login with Google',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextButton(
              onPressed: () {
                // TODO: Phone number sign in
                ref.read(isAuthenticatedProvider.notifier).state = true;
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    theme.colorScheme.primaryContainer),
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 8.0)),
                minimumSize: MaterialStateProperty.all(const Size(double.infinity,
                    0)), // This makes the button stretch horizontally
              ),
              child: Text(
                'Login with your Phone Number',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 48,
            ),
          ]),
        ),
      ),
    );
  }
}
