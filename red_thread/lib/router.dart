import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:red_thread/presentation/pages/chat.dart';
import 'package:red_thread/presentation/pages/contact_us.dart';
import 'package:red_thread/presentation/pages/onboarding.dart';
import 'package:red_thread/presentation/pages/verification.dart';
import 'package:red_thread/presentation/pages/queue.dart';
import 'package:red_thread/presentation/pages/about.dart';
import 'package:red_thread/presentation/pages/login.dart';
import 'package:red_thread/presentation/pages/account_setup.dart';
import 'package:red_thread/presentation/pages/verification.dart';
import 'package:red_thread/presentation/pages/welcome.dart';
import 'package:red_thread/providers.dart';

GoRouter createRouter(WidgetRef ref) {
  return GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (context, state) {
          final isFirstTimeUser = ref.watch(isFirstTimeUserProvider);
          final isAuthenticated = ref.watch(isAuthenticatedProvider);
          final isAccountSetupComplete =
              ref.watch(isAccountSetupCompleteProvider);
          final matchFound = ref.watch(matchFoundProvider);
          final isInCall = ref.watch(isInCallProvider);

          if (isFirstTimeUser) {
            return const WelcomePage();
          }
          if (!isAuthenticated) {
            return const LoginPage();
          }
          if (!isAccountSetupComplete) {
            return const AccountSetupPage();
          }
          if (!matchFound) {
            return const QueuePage();
          }
          return const ChatPage();
        },
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: '/contact_us',
        builder: (context, state) => const ContactUsPage(),
      ),
      GoRoute(
        path: '/verification',
        // TODO: once verification is finished redirect to /
        redirect: (context, state) {
          final isVerified = ref.watch(isVerifiedProvider);
          if (isVerified) {
            return '/';
          }
        },
        builder: (context, state) => const VerificationPage(),
      ),
    ],
  );
}
