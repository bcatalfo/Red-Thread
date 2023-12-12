import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:red_thread/amplifyconfiguration.dart';
import 'package:amplify_api/amplify_api.dart';
import 'models/ModelProvider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(const MainApp());
}

Future<void> _configureAmplify() async {
  try {
    // Add Amplify Plugins
    final amplifyAuthCognito = AmplifyAuthCognito();
    await Amplify.addPlugins([amplifyAuthCognito]);
    final api = AmplifyAPI(modelProvider: ModelProvider.instance);

    await Amplify.configure(amplifyconfig);
  } catch (e) {
    print(e);
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Authenticator(
        child: MaterialApp(
      builder: Authenticator.builder(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Red Thread'),
          actions: [SignOutButton()],
        ),
        body: MyHomePage(title: 'Red Thread'),
      ),
      theme: ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
          backgroundColor: Colors.white,
        ),
      ).copyWith(
        indicatorColor: Colors.red,
      ),
      // set the dark theme (optional)
      darkTheme: ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
          backgroundColor: Colors.black,
          brightness: Brightness.dark,
        ),
      ),
      // set the theme mode to respond to the user's system preferences (optional)
      themeMode: ThemeMode.system,
    ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final meetingNameController = TextEditingController();
  final jitsiMeet = JitsiMeet();

  void join() async {
    final attributes = await Amplify.Auth.fetchUserAttributes();
    final data = {for (var e in attributes) e.userAttributeKey.key: e.value};

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
      },
      userInfo:
          JitsiMeetUserInfo(displayName: data['Name'], email: data['email']),
    );
    jitsiMeet.join(options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
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
}

Future<Map<String, String>> getUserAttributes() async {
  final attributes = await Amplify.Auth.fetchUserAttributes();
  final data = {for (var e in attributes) e.userAttributeKey.key: e.value};
  return data;
}
