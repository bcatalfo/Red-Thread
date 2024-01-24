import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:red_thread/presentation/pages/chat.dart';
import 'package:red_thread/presentation/pages/preview.dart';
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
          final isAuthenticated = ref.watch(isAuthenticatedProvider);
          final isAccountSetupComplete =
              ref.watch(isAccountSetupCompleteProvider);
          final isVerified = ref.watch(isVerifiedProvider);
          final isFirstTimeUser = ref.watch(isFirstTimeUserProvider);

          if (isFirstTimeUser) {
            return const WelcomePage();
          }
          if (!isAuthenticated) {
            return const LoginPage();
          }
          if (!isAccountSetupComplete) {
            return const AccountSetupPage();
          }
          if (!isVerified) {
            return const VerificationPage();
          }
          return const QueuePage();
        },
      ),
      GoRoute(
        path: '/preview',
        builder: (context, state) => const PreviewPage(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatPage(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutPage(),
      ),
    ],
  );
}
