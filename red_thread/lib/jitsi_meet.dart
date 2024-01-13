import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

void join() {
  final jitsiMeet = JitsiMeet();
  var options = JitsiMeetConferenceOptions(
    // TODO: Get this from AWS
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
    // TODO: Get this from AWS
    userInfo: JitsiMeetUserInfo(
        displayName: "Ben", email: 'ben@catalfotechnologies.com'),
  );
  jitsiMeet.join(options);
}
