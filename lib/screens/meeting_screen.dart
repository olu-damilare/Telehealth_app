import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:http/http.dart';
// import 'package:telehealth_app/constants/Constants.dart';
import 'package:telehealth_app/setup/app_manager.dart';
import 'package:provider/provider.dart';
import 'package:telehealth_app/setup/sdkinitializer.dart';


import 'message_screen.dart';

class Meeting extends StatefulWidget {
  final String username;

  const Meeting({Key? key, required this.username})
      : super(key: key);

  @override
  _MeetingState createState() => _MeetingState();
}

class _MeetingState extends State<Meeting> with WidgetsBindingObserver {
  late AppManager _appManager;
  // late HmsSdkInteractor _hmsSdkInteractor;
  bool selfLeave = false;
  bool isAudioOn = true;
  bool isVideoOn = true;
  bool isRoomEnded = false;
  Offset position = Offset(10, 10);
  HMSLocalPeer? localPeer;


  // initMeeting() async {
  //   bool ans = await join(SdkInitializer.hmssdk, widget.role, widget.username);
  //   if (!ans) {
  //     const SnackBar(content: Text("Unable to join meeting."));
  //     Navigator.of(context).pop();
  //   }
  //   _appManager.startListen();
  // }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _appManager = AppManager();
    // initMeeting();
  }

  @override
  Widget build(BuildContext context) {

    final remoteTrack = context
        .select<AppManager, HMSTrack?>((user) => user.remoteVideoTrack);
    final localVideoTrack = context
        .select<AppManager, HMSVideoTrack?>((user) => user.localVideoTrack);


    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text("100ms Telehealth App"),
        actions: [
          IconButton(
              onPressed: () {
                SdkInitializer.hmssdk.switchCamera();
              },
              icon: const Icon(Icons.camera_front)),

        ],
      ),
      drawer: ListenableProvider.value(
        value: Provider.of<AppManager>(
            context,
            listen: true),
        child: MessageScreen(),
      ),

      body: Stack(
        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
            child: Center(
              child: Container(
                color: Colors.purpleAccent,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Flexible(
                        child:
                        (remoteTrack != null)
                            ? HMSVideoView(track: remoteTrack as HMSVideoTrack, matchParent: false)
                            : const Center(
                            child:
                            Icon(Icons.mic,
                            size: 40,
                            )
                            // Text('Waiting for the Doctor to join!')
                        )
                    ),

                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    child: IconButton(
                      icon: isAudioOn
                          ? const Icon(Icons.mic)
                          : const Icon(Icons.mic_off),
                      onPressed: () {
                        SdkInitializer.hmssdk.switchAudio();
                        setState(() {
                          isAudioOn = !isAudioOn;
                        });

                      },
                      color: Colors.blue,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    child: IconButton(
                      icon: isVideoOn
                          ? const Icon(Icons.videocam)
                          : const Icon(Icons.videocam_off),
                      onPressed: () {
                        SdkInitializer.hmssdk.switchVideo(isOn: isVideoOn);
                        if(!isVideoOn){
                          SdkInitializer.hmssdk.startCapturing();
                        }else{
                          SdkInitializer.hmssdk.stopCapturing();
                        }
                        setState(() {
                          isVideoOn = !isVideoOn;
                        });
                      },
                      color: Colors.blue,
                    ),
                  ),

                  CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Builder(builder: (context) {
                      return IconButton(
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          icon: const Icon(Icons.message)
                      );
                    }),

                  ),

                  CircleAvatar(
                    backgroundColor: Colors.black,
                    child: IconButton(
                      icon: const Icon(Icons.call_end),
                      onPressed: () => showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Leave the Meeting?',
                                style: TextStyle(fontSize: 24)),
                            actions: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(primary: Colors.amberAccent),
                                  onPressed: ()  { },
                                  child: const Text('Yes', style: TextStyle(fontSize: 20))),
                              ElevatedButton(
                                  onPressed: () {},
                                  child:
                                  const Text('Cancel', style: TextStyle(fontSize: 24))),
                            ],
                          )),
                      color: Colors.red,
                    ),
                  ),


                ],
              ),
            ),
          ),

          Positioned(
            left: position.dx,
            top: position.dy,
            child: Draggable<bool>(
                data: true,
                childWhenDragging: Container(),
                child: localPeerVideo(localVideoTrack),
                onDragEnd: (details) =>
                {setState(() => position = details.offset)},
                feedback: Container(
                  height: 200,
                  width: 150,
                  color: Colors.black,
                  child: Icon(
                    Icons.videocam_off_rounded,
                    color: Colors.white,
                  ),
                )
            ),
          ),
        ],
      ),
    );
  }

  Widget localPeerVideo(HMSVideoTrack? localTrack) {

    return Container(
      height: 200,
      width: 150,
      color: Colors.black,
      child:
      (isVideoOn && localTrack != null)
          ? HMSVideoView(
        track: localTrack,
      )
          : const Icon(
        Icons.videocam_off_rounded,
        color: Colors.white,
      ),
    );
  }
}