import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telehealth_app/setup/app_manager.dart';

import 'appointments_drawer.dart';
import 'book_appointment.dart';

class LandingPage extends StatefulWidget {

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final AppManager _appManager = AppManager();
  AppointmentsDrawer appointmentsDrawer = AppointmentsDrawer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      drawer: appointmentsDrawer,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: Text(
                "100ms Telehealth App",
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold
                ),
            textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 50,
              width: 200,
              child: RaisedButton(
                color: Colors.amber,
                child: Text(
                  "Book Appointment",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => ListenableProvider.value(value: _appManager, child: BookAppointment(appointmentsDrawer)))

                  );
                }
              ),
            )
          ],
        ),
      ),
    );
  }
}
