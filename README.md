
# Agora UI Kit for Flutter

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-blue?logo=flutter" alt="Platform" />
  <img alt="GitHub Workflow Status" src="https://img.shields.io/github/workflow/status/AgoraIO-Community/Flutter-UIKit/Flutter">
</p>

Instantly integrate Agora video calling or video streaming into your Flutter application.  

### Requirements

-  [An Agora developer account](https://www.agora.io/en/blog/how-to-get-started-with-agora)
- An Android or iOS Device
- A Flutter Project
  
### Installation

In your Flutter application, add the `agora_uikit` as a dependency inside your `pubspec.yaml` file.

In your Android level `build.gradle` add this at the end of the repositories:  

```css
allprojects {
	repositories {
		...
		maven { url 'https://jitpack.io' }
	}
}
```

### Device Permission

Agora Video SDK requires `camera` and `microphone` permission to start video call.

#### Android

Open the `AndroidManifest.xml` file and add the required device permissions to the file.
  
```xml
<manifest>
...
<uses-permission  android:name="android.permission.READ_PHONE_STATE"/>
<uses-permission  android:name="android.permission.INTERNET"  />
<uses-permission  android:name="android.permission.RECORD_AUDIO"  />
<uses-permission  android:name="android.permission.CAMERA"  />
<uses-permission  android:name="android.permission.MODIFY_AUDIO_SETTINGS"  />
<uses-permission  android:name="android.permission.ACCESS_NETWORK_STATE"  />
<!-- The Agora SDK requires Bluetooth permissions in case users are using Bluetooth devices.-->
<uses-permission  android:name="android.permission.BLUETOOTH"  />
...
</manifest>
```

#### iOS

Open `info.plist` and add:

-  `Privacy - Microphone Usage Description`, and add a note in the Value column.
-  `Privacy - Camera Usage Description`, and add a note in the Value column.
  
Your application can still run the voice call when it is switched to the background if the background mode is enabled. Select the app target in Xcode, click the Capabilities tab, enable Background Modes, and check Audio, AirPlay, and Picture in Picture.

## Usage

```dart
final AgoraClient client = AgoraClient(
  agoraConnectionData: AgoraConnectionData(
    appId: "<--Add Your App Id Here-->",
    channelName: "test",
  ),
  enabledPermission: [
    Permission.camera,
    Permission.microphone,
  ],
);

@override
Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            AgoraVideoViewer(client: client), 
            AgoraVideoButtons(client: client),
          ],
        ),
      ),
    ),
  );
}

```

