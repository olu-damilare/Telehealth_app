import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:telehealth_app/screens/landing_page.dart';
import 'package:telehealth_app/screens/meeting_screen.dart';
import 'package:telehealth_app/setup/app_manager.dart';
import 'package:telehealth_app/setup/sdkinitializer.dart';

import 'constants/Constants.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.purple,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '100ms Telehealth App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

   @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late AppManager _appManager;
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final FocusNode _roleNode = FocusNode();
  final FocusNode _usernameNode = FocusNode();
  bool isLoading = false;


  @override
  void initState() {
    requestPermissions();
    super.initState();
  }

  Future<bool> initMeeting() async {
    setState(() {
      isLoading = true;
    });


    bool ans = await join(SdkInitializer.hmssdk, _roleController.text, _usernameController.text);
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

  Future<bool> join(HMSSDK hmssdk, String role, String username) async {
    String roomId = Constants.roomId;
    Uri endPoint = Uri.parse("https://prod-in.100ms.live/hmsapi/telehealthapp.app.100ms.live/api/token");
    Response response = await post(endPoint, body: {
      'user_id': username,
      'room_id':roomId,
      'role': role
    });
    var body = json.decode(response.body);
    if (body == null || body['token'] == null) {
      return false;
    }

    HMSConfig config = HMSConfig(authToken: body['token'], userName: "user");
    await hmssdk.join(config: config);
    return true;
  }


  void requestPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();

    while ((await Permission.camera.isDenied)) {
      await Permission.camera.request();
    }
    while ((await Permission.microphone.isDenied)) {
      await Permission.microphone.request();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: LandingPage()
        // Container(
        //   child: ListView(
        //           children: <Widget>[
        //             Padding(
        //               padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
        //               child: Column(
        //                 children: [
        //                   TextFormField(
        //                     controller: _roleController,
        //                     style: const TextStyle(
        //                         color: Colors.purpleAccent
        //                     ),
        //                     decoration: const InputDecoration(
        //                         contentPadding: EdgeInsets.all(10),
        //                         border: OutlineInputBorder(),
        //                         labelText: 'Role',
        //                         labelStyle: TextStyle(
        //                             color: Colors.purpleAccent,
        //                             fontSize: 15,
        //                             fontWeight: FontWeight.bold
        //                         )
        //
        //                     ),
        //                     textInputAction: TextInputAction.next,
        //                     focusNode: _roleNode,
        //                   ),
        //                   const SizedBox(
        //                     height: 20,
        //                   ),
        //                   TextFormField(
        //                     controller: _usernameController,
        //                     style: const TextStyle(
        //                         color: Colors.purpleAccent
        //                     ),
        //                     decoration: const InputDecoration(
        //                         contentPadding: EdgeInsets.all(10),
        //                         border: OutlineInputBorder(),
        //                         labelText: 'Username',
        //                         labelStyle: TextStyle(
        //                             color: Colors.purpleAccent,
        //                             fontSize: 15,
        //                             fontWeight: FontWeight.bold
        //                         )
        //
        //                     ),
        //                     focusNode: _usernameNode,
        //                   ),
        //                 ],
        //               ),
        //             ),
        //             const SizedBox(
        //               height: 20,
        //             ),
        //             Container(
        //               width: 30,
        //               height: 40,
        //               child:  isLoading ?
        //               const CircularProgressIndicator(strokeWidth: 3,color: Colors.purpleAccent,)
        //               : RaisedButton(
        //                   color: Colors.amber,
        //                   onPressed: () async{
        //                     bool isJoined = await initMeeting();
        //                     if (isJoined) {
        //                       Navigator.of(context).push(MaterialPageRoute(
        //                           builder: (_) => ListenableProvider.value(value: _appManager, child: Meeting(username: _usernameController.value.text,)))
        //
        //                       );
        //                     } else {
        //                       const SnackBar(content: Text("Error"));
        //                     }
        //
        //                   },
        //                   child: const Text(
        //                     "Join meeting",
        //                     style: TextStyle(fontSize: 20),
        //                   )
        //               ),
        //             )
        //           ]
        //       ),
        // )
    );
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}