import 'package:agora_uikit/agora_uikit.dart';
import 'package:agora_uikit_example/screen_sharing.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChooseMeetTypePage(),
    );
  }
}

class VideoCallPage extends StatelessWidget {
  final AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
      appId: "6f93d947985648b3a70a0441c56aa48f",
      channelName: "test",
    ),
    enabledPermission: [
      Permission.camera,
      Permission.microphone,
    ],
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff202124),
      body: SafeArea(
        child: Stack(
          children: [
            AgoraVideoViewer(
              client: client,
              layoutType: Layout.floating,
              // floatingLayoutContainerHeight: 100,
              // floatingLayoutContainerWidth: 100,
              showNumberOfUsers: true,
              showAVState: true,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: AgoraVideoButtons(
                client: client,
                autoHideButtons: true,
                buttonAlignment: Alignment.topLeft,
                enabledButtons: [
                  BuiltInButtons.callEnd,
                  BuiltInButtons.toggleMic,
                  BuiltInButtons.toggleCamera,
                ],
                extraButtons: [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChooseMeetTypePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenSharing(
                        channelId: 'test',
                        uid: 9887,
                        screenSharingUid: 988732,
                      ),
                    ),
                  );
                },
                child: const Text('Share Screen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoCallPage(),
                    ),
                  );
                },
                child: const Text('Video Call Meeting'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
