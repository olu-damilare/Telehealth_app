import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telehealth_app/constants/Constants.dart';
import 'package:telehealth_app/models/appointment.dart';
import 'package:telehealth_app/setup/app_manager.dart';

class AppointmentsDrawer extends StatefulWidget {
  List<Appointment> appointments = [];

  @override
  _AppointmentsDrawerState createState() => _AppointmentsDrawerState();
}

class _AppointmentsDrawerState extends State<AppointmentsDrawer> {
  late AppManager _appManager;
  bool isLoading = false;

  Widget getAppointments() {
    List<Widget> appointmentsWidget = [];
    for (Appointment appointment in widget.appointments) {
      appointmentsWidget.add(ListTile(
          leading: isLoading
              ? const CircularProgressIndicator()
              : const Icon(
                  Icons.local_hospital,
                  color: Colors.red,
                ),
          title: Text(appointment.appointmentName),
          trailing: Text(DateFormat.yMd().format(appointment.appointmentDate),
              softWrap: true),
          onTap: () {}));
    }
    return Column(children: appointmentsWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(children: [
      AppBar(
        title: const Text('Your appointments'),
        // automaticallyImplyLeading: false,
      ),
      const Divider(),
      widget.appointments.isEmpty
          ? const Center(
              child: Text("You have no appointments"),
            )
          : getAppointments()
    ]));
  }
}
