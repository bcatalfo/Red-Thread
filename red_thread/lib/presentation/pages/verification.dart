import 'package:flutter/material.dart';
import 'package:red_thread/presentation/drawer.dart';
import 'package:red_thread/presentation/face_detector_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:red_thread/providers.dart';
import 'dart:io';

enum VerificationState { capturing, verifying, success, failure }

final smileProbabilityProvider = StateProvider<double>((ref) => 0.0);
final numberOfFacesDetectedProvider = StateProvider<int>((ref) => 0);
final isFaceCenteredProvider = StateProvider<bool>((ref) => false);

class VerificationPage extends ConsumerStatefulWidget {
  const VerificationPage({super.key});

  @override
  VerificationPageState createState() => VerificationPageState();
}

class VerificationPageState extends ConsumerState<VerificationPage> {
  var _verificationState = VerificationState.capturing;
  String? imagePath;

  @override
  Widget build(BuildContext context) {
    final smileProbability = ref.watch(smileProbabilityProvider);
    final numberOfFacesDetected = ref.watch(numberOfFacesDetectedProvider);
    final isFaceCentered = ref.watch(isFaceCenteredProvider);
    String alertText;
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    switch (_verificationState) {
      case VerificationState.capturing:
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
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            ref.read(numberOfFacesDetectedProvider.notifier).state = 0;
            ref.read(isFaceCenteredProvider.notifier).state = false;
            ref.read(smileProbabilityProvider.notifier).state = 0.0;
            debugPrint("Post frame callback");
            // TODO: take picture and get the file path
            _verificationState = VerificationState.verifying;
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
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: FaceDetectorView()),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              ref.read(numberOfFacesDetectedProvider.notifier).state = 0;
              ref.read(isFaceCenteredProvider.notifier).state = false;
              ref.read(smileProbabilityProvider.notifier).state = 0.0;
              Navigator.pop(context);
            },
            child: const Icon(Icons.cancel),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          backgroundColor: theme.colorScheme.surface,
        );
      case VerificationState.verifying:
        return Scaffold(
          drawer: myDrawer(context, ref),
          appBar: myAppBar(context, ref),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(25.0, 8.0, 8.0, 8.0),
                child: Text(
                    "Picture taken! Feel free to retake as many times as you wish.",
                    style: theme.textTheme.displayLarge),
              ),
              imagePath != null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: Image.file(File(imagePath!))),
                    )
                  : const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              ref.read(numberOfFacesDetectedProvider.notifier).state = 0;
              ref.read(isFaceCenteredProvider.notifier).state = false;
              ref.read(smileProbabilityProvider.notifier).state = 0.0;
              Navigator.pop(context);
            },
            child: const Icon(Icons.cancel),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          backgroundColor: theme.colorScheme.surface,
        );
      case VerificationState.success:
        throw UnimplementedError();
      case VerificationState.failure:
        throw UnimplementedError();
    }
  }
}
