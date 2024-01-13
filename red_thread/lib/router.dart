import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:red_thread/presentation/pages/video_preview.dart';

GoRouter createRouter(WidgetRef ref) {
  return GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (context, state) => const VideoPreview(),
      ),
      // Add more routes here
    ],
  );
}
