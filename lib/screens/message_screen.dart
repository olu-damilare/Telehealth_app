import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:provider/provider.dart';
import 'package:telehealth_app/models/message.dart';
import 'package:telehealth_app/setup/app_manager.dart';
import 'package:telehealth_app/setup/sdkinitializer.dart';

class MessageScreen extends StatefulWidget {
  MessageScreen({Key? key}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late double width;
  late List<HMSRole> hmsRoles;
  TextEditingController messageTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    List<Message> _messages =
        Provider.of<AppManager>(context, listen: true).messages;
    Provider.of<AppManager>(context, listen: true).isNewMessage = false;
    final localPeer = Provider.of<AppManager>(context, listen: false).localPeer;
    return Drawer(
      child: SafeArea(
          bottom: true,
          minimum:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  color: Colors.amber,
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Message",
                          style: TextStyle(color: Colors.black, fontSize: 20.0),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Icon(
                          Icons.clear,
                          size: 25.0,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Observer(
                    builder: (_) {
                      // if (!_appManager.isMeetingStarted) {
                      //   return const SizedBox();
                      // }
                      if (_messages.isEmpty) {
                        return Center(child: const Text('No messages'));
                      }
                      return ListView.separated(
                        itemCount: _messages.length,
                        itemBuilder: (itemBuilder, index) {
                          return Container(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _messages[index].senderName,
                                        style: const TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      _messages[index].time
                                          .toString(),
                                      style: const TextStyle(
                                          fontSize: 10.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w900),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  _messages[index].message
                                      .toString(),
                                  style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider();
                        },
                      );
                    },
                  ),
                ),
                Container(
                  color: Colors.amberAccent,
                  margin: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 5.0, left: 5.0),
                        child: TextField(
                          autofocus: true,
                          controller: messageTextController,
                          decoration: const InputDecoration(
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 15, bottom: 11, top: 11, right: 15),
                              hintText: "Input a Message"),
                        ),
                        width: 230,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (messageTextController.text.trim().isNotEmpty) {
                            SdkInitializer.hmssdk.sendBroadcastMessage(
                                message: messageTextController.text);
                            setState(() {
                              _messages.add(Message(
                                  message: messageTextController.text.trim(),
                                  time: DateTime.now().toString(),
                                  peerId: "localUser",
                                  senderName: localPeer.name));
                            });
                            messageTextController.text = "";
                          }

                          // String message = messageTextController.text;
                          // if (message.isEmpty) return;
                          // _appManager.sendBroadcastMessage(message);
                          // messageTextController.clear();
                        },
                        child: const Icon(
                          Icons.send,
                          size: 40.0,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}

void chatMessages(BuildContext context, AppManager appManager) {
  showModalBottomSheet(
      context: context,
      builder: (ctx) => MessageScreen(),
      isScrollControlled: true);
}
