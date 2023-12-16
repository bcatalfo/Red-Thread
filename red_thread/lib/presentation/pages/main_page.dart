import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import '../../domain/user_repository.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final UserRepository userRepository = UserRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
            onPressed: join,
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0))),
            ),
            child: const Text("Join")),
      ),
    );
  }

  JitsiMeetConferenceOptions dateOptions(data) {
    return JitsiMeetConferenceOptions(
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
      },
      userInfo:
          JitsiMeetUserInfo(displayName: data['name'], email: data['email']),
    );
  }

  void join() async {
    final data = await userRepository.getUserAttributes();
    var options = dateOptions(data);

    JitsiMeet().join(options);
  }
}
