import 'dart:async';
import 'package:flutter/material.dart';
import 'package:red_thread/presentation/drawer_closed.dart';
import 'package:red_thread/presentation/face_detector_view.dart';
import 'package:red_thread/presentation/themes.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final smileProbabilityProvider = StateProvider<double>((ref) => 0.0);
final numberOfFacesDetectedProvider = StateProvider<int>((ref) => 0);
final isFaceCenteredProvider = StateProvider<bool>((ref) => false);
final inQueueProvider = StateProvider<bool>((ref) => false);
final secsInQueueProvider = StateProvider<int>((ref) => 0);

class VideoPreview extends ConsumerStatefulWidget {
  const VideoPreview({super.key});

  @override
  VideoPreviewState createState() => VideoPreviewState();
}

class VideoPreviewState extends ConsumerState<VideoPreview> {
  final jitsiMeet = JitsiMeet();

  void join() {
    var options = JitsiMeetConferenceOptions(
      serverURL: "https://jitsi.member.fsf.org",
      room: "jitsiIsAwesomeWithFlutter",
      configOverrides: {
        "startWithAudioMuted": false,
        "startWithVideoMuted": false,
        "disableModeratorIndicator": true,
        "prejoinPageEnabled": false,
        "breakoutRooms.hideAddRoomButton": true,
        "breakoutRooms.hideAutoAssignButton": true,
        "breakoutRooms.hideJoinRoomButton": true,
        "minHeightForQualityLvl.360": "low",
        "minHeightForQualityLvl.720": "standard",
        "minHeightForQualityLvl.1080": "high",
        "resolution": 1080,
      },
      featureFlags: {
        'unsaferoomwarning.enabled': false,
        'add-people.enabled': false,
        'filmstrip.enabled': true,
        'breakout-rooms.enabled': false,
        'calendar.enabled': false,
        'call-integration.enabled': false,
        'android.screensharing.enabled': false,
        'live-streaming.enabled': false,
        'car-mode.enabled': false,
        'kick-out.enabled': false,
        'chat.enabled': false,
        'invite.enabled': false,
        'meeting-name.enabled': false,
        'raise-hand.enabled': false,
        'recording.enabled': false,
        'server-url-change.enabled': false,
        'tile-view.enabled': false,
        'toolbox.alwaysVisible': false,
        'video-share.enabled': false,
        'welcomepage.enabled': false,
        'lobby-mode.enabled': false,
        'fullscreen.enabled': false,
        'pip.enabled': false,
      },
      userInfo: JitsiMeetUserInfo(
          displayName: "Ben", email: 'ben@catalfotechnologies.com'),
    );
    jitsiMeet.join(options);
  }

  Timer? _timer;

  void startOrStopTimer(bool inQueue) {
    if (inQueue) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        ref.read(secsInQueueProvider.notifier).state++;
      });
    } else {
      _timer?.cancel();
      ref.read(secsInQueueProvider.notifier).state = 0; // Reset timer
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final smileProbability = ref.watch(smileProbabilityProvider);
    final numberOfFacesDetected = ref.watch(numberOfFacesDetectedProvider);
    final isFaceCentered = ref.watch(isFaceCenteredProvider);
    final inQueue = ref.watch(inQueueProvider);
    final secsInQueue = ref.watch(secsInQueueProvider);

    String formatTime(int totalSeconds) {
      final int minutes = totalSeconds ~/ 60;
      final int seconds = totalSeconds % 60;
      return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    }

    String alertText() {
      if (numberOfFacesDetected == 0) {
        return 'Get in the frame!';
      }
      if (numberOfFacesDetected > 1) {
        return 'Move your friend away!';
      }
      if (isFaceCentered == false) {
        return 'Center your face!';
      }
      if (smileProbability < 0.5) {
        return 'Smile more!';
      }
      return 'You look great!';
    }

    return Scaffold(
        drawer: myDrawer,
        appBar: myAppBar,
        body: Column(
          children: [
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Text(alertText(), style: theme.textTheme.displayLarge),
              ),
            ),
            Flexible(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                      inQueue ? 'Finding you a match ${formatTime(secsInQueue)}' : 'Not in queue',
                      style: theme.textTheme.displayMedium),
                )),
            const Flexible(
              flex: 15,
              child: FaceDetectorView(),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.surface,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          height: 100.0, // Set your desired height
          width: 100.0, // Set your desired width
          child: FittedBox(
              child: FloatingActionButton(
            onPressed: () {
              final currentlyInQueue = ref.read(inQueueProvider);
              ref.read(inQueueProvider.notifier).state = !currentlyInQueue;

              // Start or stop the timer based on the new inQueue state
              startOrStopTimer(!currentlyInQueue);
            },
            backgroundColor: alertText() == 'You look great!' || inQueue
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withOpacity(0.38),
            child: Text(
              inQueue ? 'Leave Queue' : 'Join Queue',
              style: TextStyle(
                color: alertText() == 'You look great!' || inQueue
                    ? colorScheme.onPrimary
                    : colorScheme.onPrimary.withOpacity(0.38),
              ),
              textAlign: TextAlign.center,
            ),
          )),
        ));
  }
}
