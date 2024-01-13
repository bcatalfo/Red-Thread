import 'package:flutter/material.dart';
import 'package:red_thread/presentation/drawer_closed.dart';
import 'package:red_thread/presentation/face_detector_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:red_thread/jitsi_meet.dart';

final smileProbabilityProvider = StateProvider<double>((ref) => 0.0);
final numberOfFacesDetectedProvider = StateProvider<int>((ref) => 0);
final isFaceCenteredProvider = StateProvider<bool>((ref) => false);
final inQueueProvider = StateProvider<bool>((ref) => false);
final secsInQueueProvider = StateProvider<int>((ref) => 0);

class PreviewPage extends ConsumerStatefulWidget {
  const PreviewPage({super.key});

  @override
  PreviewPageState createState() => PreviewPageState();
}

class PreviewPageState extends ConsumerState<PreviewPage> {
  void joinChat(BuildContext context) {
    join();
    context.go('/chat');
  }

  @override
  Widget build(BuildContext context) {
    final smileProbability = ref.watch(smileProbabilityProvider);
    final numberOfFacesDetected = ref.watch(numberOfFacesDetectedProvider);
    final isFaceCentered = ref.watch(isFaceCenteredProvider);
    String alertText;
    final theme = Theme.of(context);

    if (numberOfFacesDetected == 0) {
      alertText = 'Get in the frame!';
    } else if (numberOfFacesDetected > 1) {
      alertText = 'Move your friend away!';
    } else if (isFaceCentered == false) {
      alertText = 'Center your face!';
    } else if (smileProbability < 0.5) {
      alertText = 'Smile more!';
    } else {
      alertText = 'You look great!';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        joinChat(context);
      });
    }

    return Scaffold(
      drawer: myDrawer,
      appBar: myAppBar,
      body: Column(
        children: [
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25.0, 8.0, 8.0, 8.0),
              child: Text(alertText, style: theme.textTheme.displayLarge),
            ),
          ),
          const Flexible(
            flex: 15,
            child: FaceDetectorView(),
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.surface,
    );
  }
}
