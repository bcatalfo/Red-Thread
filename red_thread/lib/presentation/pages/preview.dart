import 'package:flutter/material.dart';
import 'package:red_thread/presentation/drawer.dart';
import 'package:red_thread/presentation/face_detector_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:red_thread/providers.dart';

final smileProbabilityProvider = StateProvider<double>((ref) => 0.0);
final numberOfFacesDetectedProvider = StateProvider<int>((ref) => 0);
final isFaceCenteredProvider = StateProvider<bool>((ref) => false);

class PreviewPage extends ConsumerStatefulWidget {
  const PreviewPage({super.key});

  static const String routeName = '/preview';

  @override
  PreviewPageState createState() => PreviewPageState();
}

class PreviewPageState extends ConsumerState<PreviewPage> {
  bool _minimizePreview = false;

  @override
  Widget build(BuildContext context) {
    final smileProbability = ref.watch(smileProbabilityProvider);
    final numberOfFacesDetected = ref.watch(numberOfFacesDetectedProvider);
    final isFaceCentered = ref.watch(isFaceCenteredProvider);
    String alertText;
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    // TODO: add the is ready var here. when ur all smiling and shit at the end minimize ur p\review andd= show the call

    if (numberOfFacesDetected == 0) {
      alertText = 'Get in the frame!';
    } else if (numberOfFacesDetected > 1) {
      alertText = 'Move your friend away!';
    } else if (isFaceCentered == false) {
      alertText = 'Center your face!';
    } else if (smileProbability < 0.5) {
      alertText = 'Smile more!';
      setState(() {
        _minimizePreview = true;
      });
    } else {
      alertText = 'You look great!';
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ref.read(isPreviewCompleteProvider.notifier).state = true;
        ref.read(numberOfFacesDetectedProvider.notifier).state = 0;
        ref.read(isFaceCenteredProvider.notifier).state = false;
        ref.read(smileProbabilityProvider.notifier).state = 0.0;
        debugPrint("Post frame callback");
      });
    }

    return Scaffold(
      drawer: myDrawer(context, ref),
      appBar: myAppBar(context, ref),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25.0, 8.0, 8.0, 8.0),
            child: Text(alertText, style: theme.textTheme.displayLarge),
          ),
          Stack(
            children: [
              Container(
                color: theme.colorScheme.surfaceVariant,
                child: Center(child: Image.asset('assets/images/hot chinese.jpeg'))
              ),
              Align(
            alignment: Alignment.bottomRight,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 750),
              width: _minimizePreview ? screenSize.width * 0.2 : screenSize.width,
              height: _minimizePreview ? screenSize.height * 0.2 : screenSize.height,
              child: const FaceDetectorView(), // Your FaceDetectorView here
              // Additional styling or logic...
            ),
          )
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(matchFoundProvider.notifier).state = false;
          ref.read(numberOfFacesDetectedProvider.notifier).state = 0;
          ref.read(isFaceCenteredProvider.notifier).state = false;
          ref.read(smileProbabilityProvider.notifier).state = 0.0;
        },
        child: const Icon(Icons.cancel),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: theme.colorScheme.surface,
    );
  }
}
