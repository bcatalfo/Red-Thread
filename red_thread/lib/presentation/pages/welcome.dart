import 'package:flutter/gestures.dart';
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  WelcomePageState createState() => WelcomePageState();
}

class WelcomePageState extends ConsumerState<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18l = AppLocalizations.of(context)!;

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
              i18l.appName,
              style: theme.textTheme.displayLarge?.copyWith(
                color: const Color(0xffff5757),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const SizedBox(
              height: 48,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                i18l.slogan,
                style: theme.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyLarge,
                text: 'By tapping "Login" or "Register", you agree to our ',
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
                context.push('/login');
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    theme.colorScheme.primaryContainer),
                padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 8.0)),
                minimumSize: WidgetStateProperty.all(const Size(
                    double.infinity,
                    0)), // This makes the button stretch horizontally
              ),
              child: Text(
                i18l.login,
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
                context.push('/register');
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    theme.colorScheme.primaryContainer),
                padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 8.0)),
                minimumSize: WidgetStateProperty.all(const Size(
                    double.infinity,
                    0)), // This makes the button stretch horizontally
              ),
              child: Text(
                i18l.register,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            TextButton(
              onPressed: () {},
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 8.0)),
                minimumSize: WidgetStateProperty.all(const Size(
                    double.infinity,
                    0)), // This makes the button stretch horizontally
              ),
              child: Text(
                'Having trouble logging in?',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurface),
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
