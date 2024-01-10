import 'package:flutter/material.dart';
import 'package:red_thread/presentation/drawer_closed.dart';
import 'package:red_thread/presentation/face_detector_view.dart';
import 'package:red_thread/presentation/themes.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final smileProbabilityProvider = StateProvider<double>((ref) => 0.0);
final numberOfFacesDetectedProvider = StateProvider<int>((ref) => 0);
final isFaceCenteredProvider = StateProvider<bool>((ref) => false);


class VideoPreview extends ConsumerWidget {
  final jitsiMeet = JitsiMeet();

  VideoPreview({super.key});

  void join(){
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
      userInfo:
          JitsiMeetUserInfo(displayName: "Ben", email: 'ben@catalfotechnologies.com'),
    );
    jitsiMeet.join(options);
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final smileProbability = ref.watch(smileProbabilityProvider);
    final numberOfFacesDetected = ref.watch(numberOfFacesDetectedProvider);
    final isFaceCentered = ref.watch(isFaceCenteredProvider);

    return Scaffold(
        drawer: myDrawer,
        appBar: myAppBar,
        body: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Text('Get lookin snazzy', style: theme.textTheme.displayLarge), 
              Text('Smile Probability: $smileProbability', style: theme.textTheme.displayMedium),
              Text('Number of Faces Detected: $numberOfFacesDetected', style: theme.textTheme.displayMedium),
              Text('Is Face Centered: $isFaceCentered', style: theme.textTheme.displayMedium),
              FaceDetectorView(),
            ],
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          height: 100.0, // Set your desired height
          width: 100.0, // Set your desired width
          child: FittedBox(
            child: FloatingActionButton(
              onPressed: () {
                // show an alert dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Join Queue'),
                      content: Text('Are you sure you want to join the queue?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            join();
                          },
                          child: Text('Join'),
                        ),
                      ],
                    );
                  },
                );
              },
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                'Join Queue',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ));
  }
}
