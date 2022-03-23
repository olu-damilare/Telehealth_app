import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:telehealth_app/constants/Constants.dart';
import 'package:telehealth_app/models/appointment.dart';
import 'package:telehealth_app/setup/app_manager.dart';
import 'package:telehealth_app/setup/sdkinitializer.dart';

import 'meeting_screen.dart';

class AppointmentsDrawer extends StatefulWidget {
  List<Appointment> appointments = [];

  @override
  _AppointmentsDrawerState createState() => _AppointmentsDrawerState();
}

class _AppointmentsDrawerState extends State<AppointmentsDrawer> {
  late AppManager _appManager;
  bool isLoading = false;


  Future<bool> join(HMSSDK hmssdk, String username) async {
    String roomId = Constants.roomId;
    Uri endPoint = Uri.parse("https://prod-in.100ms.live/hmsapi/decoder.app.100ms.live/api/token");
    Response response = await post(endPoint, body: {
      'user_id': username,
      'room_id':roomId,
      'role': "host"
    });
    var body = json.decode(response.body);
    if (body == null || body['token'] == null) {
      return false;
    }
    print(body);
    HMSConfig config = HMSConfig(authToken: body['token'], userName: username);
    await hmssdk.join(config: config);
    return true;
  }


  Future<bool> initiateMeeting(String username) async {
    setState(() {
      isLoading = true;
    });

    SdkInitializer.hmssdk.build();
    bool ans = await join(SdkInitializer.hmssdk, username);
    if (!ans) {
      return false;

    }
    _appManager = AppManager();
    _appManager.startListen();
    setState(() {
      isLoading = false;
    });
    return true;
  }

  Widget getAppointments(){
    List<Widget> appointmentsWidget = [];
    for(Appointment appointment in widget.appointments){
     appointmentsWidget.add(
         ListTile(
        leading: isLoading ? CircularProgressIndicator()
        : Icon(
            Icons.local_hospital,
          color: Colors.red,
        ),
          title: Text(appointment.appointmentName),
          trailing: Text(DateFormat.yMd().format(appointment.appointmentDate), softWrap: true),
           onTap: () async{
          bool isJoined = await initiateMeeting(appointment.username);
               if (isJoined) {
                 Navigator.of(context).push(MaterialPageRoute(
                     builder: (_) =>
                         ListenableProvider.value(value: _appManager,
                             child: Meeting(username: appointment.username,)))

                 );
               } else {
                 const SnackBar(content: Text("Unable to join meeting"));
                 Navigator.of(context).pop();
               }
             }
      )
     );

    }
    return Column(
        children: appointmentsWidget
    );

  }


  @override
  Widget build(BuildContext context) {
    return Drawer(

        child: Column(
          children: [
            AppBar(
              title: Text('Your appointments'),
              // automaticallyImplyLeading: false,
            ),
            Divider(),
            widget.appointments.isEmpty ?
                Center(
                  child: Text("You have no appointments"),
                )
                : getAppointments()
            ]
        )
    );
  }
}
