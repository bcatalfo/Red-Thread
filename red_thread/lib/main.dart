import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:red_thread/amplifyconfiguration.dart';

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
  void join() {
    var options = JitsiMeetConferenceOptions(
      serverURL: "https://jitsi.member.fsf.org",
      room: "jitsiIsAwesomeWithFlutter",
      configOverrides: {
        "startWithAudioMuted": false,
        "startWithVideoMuted": false,
        "disableModeratorIndicator": true,
        "subject": "Jitsi with Flutter",
      },
      featureFlags: {"unsaferoomwarning.enabled": false},
      userInfo: JitsiMeetUserInfo(
          displayName: "Flutter user", email: "user@example.com"),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 250,
              height: 50,
              child: TextField(
                controller: meetingNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter meeting name',
                ),
              ),
            ),
            SizedBox(
              width: 100,
              height: 50,
              child: FilledButton(
                  onPressed: join,
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0))),
                  ),
                  child: const Text("Join")),
            ),
          ],
        ),
      ),
    );
  }
}
