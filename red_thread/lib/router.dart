import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:red_thread/presentation/pages/chat.dart';
import 'package:red_thread/presentation/pages/contact_us.dart';
import 'package:red_thread/presentation/pages/verification.dart';
import 'package:red_thread/presentation/pages/queue.dart';
import 'package:red_thread/presentation/pages/about.dart';
import 'package:red_thread/presentation/pages/welcome.dart';
import 'package:red_thread/presentation/pages/account_setup.dart';
import 'package:red_thread/providers.dart';
import 'package:red_thread/presentation/pages/login.dart';

GoRouter createRouter(WidgetRef ref) {
  return GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (context, state) {
          final isAuthenticated = ref.watch(isAuthenticatedProvider);
          final matchFound = ref.watch(matchProvider) != null;

          if (!isAuthenticated) {
            return const WelcomePage();
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
        builder: (context, state) => const VerificationPage(),
      ),
      GoRoute(
        path: "/login",
        pageBuilder: (context, state) {
          return CustomTransitionPage(
              child: const LoginPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              });
        },
      ),
      GoRoute(
        path: "/register",
        builder: (context, state) => const AccountSetupPage(),
      ),
    ],
  );
}
