import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:http/http.dart';
import 'package:telehealth_app/constants/Constants.dart';
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

  // Future<bool> join(HMSSDK hmssdk, String role, String username) async {
  //   String roomId = Constants.roomId;
  //   Uri endPoint = Uri.parse("https://prod-in.100ms.live/hmsapi/telehealthapp.app.100ms.live/api/token");
  //   Response response = await post(endPoint, body: {
  //     'user_id': username,
  //     'room_id':roomId,
  //     'role': role
  //   });
  //   var body = json.decode(response.body);
  //   print(body);
  //   if (body == null || body['token'] == null) {
  //     return false;
  //   }
  //
  //   HMSConfig config = HMSConfig(authToken: body['token'], userName: "user");
  //   await hmssdk.join(config: config);
  //   return true;
  // }



  @override
  Widget build(BuildContext context) {


    final _isVideoOff = context.select<AppManager, bool>(
            (user) => user.remoteVideoTrack?.isMute ?? true);
    final _isAudioOff = context.select<AppManager, bool>(
            (user) => user.remoteAudioTrack?.isMute ?? true);
    final _peer =
    context.select<AppManager, HMSPeer?>((user) => user.remotePeer);
    final remoteTrack = context
        .select<AppManager, HMSTrack?>((user) => user.remoteVideoTrack);
    final localVideoTrack = context
        .select<AppManager, HMSVideoTrack?>((user) => user.localVideoTrack);
    bool isNewMessage =
    context.select<AppManager, bool>((user) => user.isNewMessage);


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
        child: MessageScreen(appManager: _appManager,),
      ),

      body: Stack(
        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
            child: Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Flexible(
                    child:
                    (remoteTrack != null)
                      ? HMSVideoView(track: remoteTrack as HMSVideoTrack, matchParent: false)
                            : const Center(
                                child: Text('Waiting for the other part to join!'))
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
                                  onPressed: ()  {
                                    SdkInitializer.hmssdk.leave();
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Yes', style: TextStyle(fontSize: 20))),
                              ElevatedButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child:
                                  const Text('Cancel', style: TextStyle(fontSize: 24))),
                            ],
                          )),


                      //     () {
                      //   _appManager.leave();
                      //   selfLeave = true;
                      //   isRoomEnded = true;
                      //   Navigator.pop(context);
                      // },
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
    print("local peer --> $localPeer");
    print("local track --> $localTrack");
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


//
// Widget videoPageView({required List<PeerTracKNode> filteredList}) {
//     List<Widget> pageChild = [];
//     if (_appManager.currentScreenShareTrack != null) {
//       pageChild.add(RotatedBox(
//         quarterTurns: 1,
//         child: Container(
//             margin:
//             const EdgeInsets.only(bottom: 0, left: 0, right: 100, top: 0),
//             child: Observer(builder: (context) {
//               return HMSVideoView(
//                   track: _appManager.currentScreenShareTrack as HMSVideoTrack);
//             })),
//       ));
//     }
//     for (int i = 0; i < filteredList.length; i = i + 6) {
//       if (filteredList.length - i > 5) {
//         Widget temp = singleVideoPageView(6, i, filteredList);
//         pageChild.add(temp);
//       } else {
//         Widget temp =
//         singleVideoPageView(filteredList.length - i, i, filteredList);
//         pageChild.add(temp);
//       }
//     }
//     return PageView(
//       children: pageChild,
//     );
//   }
//
//   Widget singleVideoPageView(int count, int index, List<PeerTracKNode> tracks) {
//     return Align(
//         alignment: Alignment.center,
//         child: Container(
//             margin: const EdgeInsets.only(
//                 bottom: 100, left: 10, right: 10, top: 10),
//             child: Observer(builder: (context) {
//               return videoViewGrid(count, index, tracks);
//             })));
//   }
//
//   Widget videoViewGrid(int count, int start, List<PeerTracKNode> tracks) {
//     ObservableMap<String, HMSTrackUpdate> trackUpdate =
//         _appManager.trackStatus;
//     return GridView.builder(
//       itemCount: count,
//       physics: const NeverScrollableScrollPhysics(),
//       itemBuilder: (itemBuilder, index) {
//         return Observer(builder: (context) {
//           return videoTile(
//               tracks[start + index],
//               !(tracks[start + index].track?.peer?.isLocal ?? false
//                   ? !isVideoOn
//                   : (trackUpdate[tracks[start + index].peerId]) ==
//                   HMSTrackUpdate.trackMuted),
//               MediaQuery.of(context).size.width / 2 - 25);
//         });
//       },
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           mainAxisSpacing: 5,
//           crossAxisSpacing: 5,
//           childAspectRatio: 0.88),
//     );
//   }
//
//   Widget videoTile(
//       PeerTracKNode track, bool isVideoMuted, double size) {
//     return Stack(
//       children: [
//         Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Align(
//               alignment: Alignment.center,
//               child: SizedBox(
//                 width: size,
//                 height: size,
//                 child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: (track.track != null && isVideoMuted)
//                         ? HMSVideoView(
//                       track: track.track as HMSVideoTrack,
//                     )
//                         : Container(
//                         width: 200,
//                         height: 200,
//                         color: Colors.black,
//                         child: Center(
//                           child: CircleAvatar(
//                             radius: 50,
//                             backgroundColor: Colors.green,
//                             child: track.name.contains(" ")
//                                 ? Text(
//                               (track.name.toString().substring(0, 1) +
//                                   track.name
//                                       .toString()
//                                       .split(" ")[1]
//                                       .substring(0, 1))
//                                   .toUpperCase(),
//                               style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w700),
//                             )
//                                 : Text(track.name
//                                 .toString()
//                                 .substring(0, 1)
//                                 .toUpperCase()),
//                           ),
//                         ))),
//               ),
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Text(
//                 track.name,
//                 style: const TextStyle(fontWeight: FontWeight.w700),
//               ),
//             )
//           ],
//         ),
//
//       ],
//     );
//   }


