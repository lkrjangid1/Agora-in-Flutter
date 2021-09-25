import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ScreenSharing extends StatefulWidget {
  final String channelId;
  final int uid;
  final int screenSharingUid;
  const ScreenSharing(
      {Key key, this.channelId, this.screenSharingUid, this.uid})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ScreenSharing> {
  RtcEngine _engine;
  bool startPreview = false, isJoined = false, screenSharing = false;
  List<int> remoteUid = [];

  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  @override
  void dispose() {
    super.dispose();
    _engine.destroy();
  }

  _initEngine() {
    RtcEngine.createWithContext(
            RtcEngineContext('6f93d947985648b3a70a0441c56aa48f'))
        .then((value) {
      setState(() {
        _engine = value;
        _addListeners();
        () async {
          await _engine.enableVideo();
          if (kIsWeb) {
            await _engine.startScreenCapture(0);
          } else {
            await _engine.startPreview();
          }
          await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
          await _engine.setClientRole(ClientRole.Broadcaster);
          setState(() {
            startPreview = true;
          });
        }();
      });
    });
  }

  _addListeners() {
    _engine.setEventHandler(RtcEngineEventHandler(
      warning: (warningCode) {
        log('warning ${warningCode}');
      },
      error: (errorCode) {
        log('error ${errorCode}');
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        log('joinChannelSuccess ${channel} ${uid} ${elapsed}');
        setState(() {
          isJoined = true;
        });
      },
      userJoined: (uid, elapsed) {
        log('userJoined  ${uid} ${elapsed}');
        if (uid == widget.screenSharingUid) {
          return;
        }
        setState(() {
          remoteUid.add(uid);
        });
      },
      remoteVideoStateChanged: (uid, state, reason, elapsed) {
        log('remoteVideoStateChanged ${uid} ${state} ${reason} ${elapsed}');
        // if (state == VideoRemoteState.Decoding) {
        //   setState(() {
        //     remoteUid.add(uid);
        //   });
        // }
      },
      userOffline: (uid, reason) {
        log('userOffline  ${uid} ${reason}');
        setState(() {
          remoteUid.removeWhere((element) => element == uid);
        });
      },
      leaveChannel: (stats) {
        log('leaveChannel ${stats.toJson()}');
        setState(() {
          isJoined = false;
          remoteUid.clear();
        });
      },
    ));
  }

  _joinChannel() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();
    }
    await _engine.joinChannel(null, widget.channelId, null, widget.uid);
  }

  _leaveChannel() async {
    await _engine.leaveChannel();
  }

  _startScreenShare() async {
    final helper = _engine.getScreenShareHelper();
    helper.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
      log('ScreenSharing joinChannelSuccess ${channel} ${uid} ${elapsed}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'ScreenSharing joinChannelSuccess ${channel} ${uid} ${elapsed}'),
      ));
      final windows = _engine.enumerateWindows();
      final window = windows[0];
      helper.startScreenCaptureByWindowId(window.id).then((value) {
        setState(() {
          screenSharing = true;
        });
      }).catchError((err) {
        log('startScreenCaptureByWindowId $err');
      });
    }));
    await helper
        .initialize(RtcEngineContext('6f93d947985648b3a70a0441c56aa48f'));
    await helper.disableAudio();
    await helper.enableVideo();
    await helper.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await helper.setClientRole(ClientRole.Broadcaster);
    await helper.joinChannel(
        null, widget.channelId, null, widget.screenSharingUid);
  }

  _stopScreenShare() async {
    final helper = _engine.getScreenShareHelper();
    await helper.destroy().then((value) {
      setState(() {
        screenSharing = false;
      });
    }).catchError((err) {
      log('_stopScreenShare $err');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: isJoined ? _leaveChannel : _joinChannel,
                    child: Text('${isJoined ? 'Leave' : 'Join'} channel'),
                  ),
                )
              ],
            ),
            _renderVideo(),
          ],
        ),
        if (!kIsWeb)
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed:
                      screenSharing ? _stopScreenShare : _startScreenShare,
                  child:
                      Text('${screenSharing ? 'Stop' : 'Start'} screen share'),
                ),
              ],
            ),
          )
      ],
    );
  }

  _renderVideo() {
    return Expanded(
        child: Stack(
      children: [
        Row(
          children: [
            if (startPreview)
              Expanded(
                  flex: 1,
                  child: kIsWeb
                      ? RtcLocalView.SurfaceView()
                      : RtcLocalView.TextureView()),
            if (screenSharing)
              Expanded(flex: 1, child: RtcLocalView.TextureView.screenShare()),
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.of(remoteUid.map(
                (e) => Container(
                  width: 120,
                  height: 120,
                  child: kIsWeb
                      ? RtcRemoteView.SurfaceView(
                          uid: e,
                          channelId: widget.channelId,
                        )
                      : RtcRemoteView.TextureView(
                          uid: e,
                          channelId: widget.channelId,
                        ),
                ),
              )),
            ),
          ),
        )
      ],
    ));
  }
}
