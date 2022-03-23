import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telehealth_app/models/appointment.dart';
import 'package:telehealth_app/screens/appointments_drawer.dart';

class BookAppointment extends StatefulWidget {
  final AppointmentsDrawer appointmentsDrawer;

  const BookAppointment(this.appointmentsDrawer);

   @override
  State<BookAppointment> createState() => _BookAppointmentState();
}

class _BookAppointmentState extends State<BookAppointment> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _appointmentNameController = TextEditingController();
  final FocusNode _usernameNode = FocusNode();
  final FocusNode _appointmentNameNode = FocusNode();
  DateTime? _selectedDate;

  // This method displays the date picker to select the appointment date.
  void _displayDatePicker(){
    showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2023)
    ).then((value)  {
      if (value == null) return;
      setState(() {
        _selectedDate = value;
      });
    });
  }

  //This method adds the created appointment to the appointments screen.
  void _addNewAppointment() {
    final appointment = Appointment(
      _usernameController.value.text,
      _appointmentNameController.value.text,
      _selectedDate as DateTime,
    );

    setState(() {
      widget.appointmentsDrawer.appointments.add(appointment);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book an appointment'),
        centerTitle: true,
      ),
      body: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(
                        color: Colors.purpleAccent
                    ),
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        border: OutlineInputBorder(),
                        labelText: 'Username',
                        labelStyle: TextStyle(
                            color: Colors.purpleAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.bold
                        )

                    ),
                    textInputAction: TextInputAction.next,
                    focusNode: _usernameNode,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _appointmentNameController,
                    style: const TextStyle(
                        color: Colors.purpleAccent
                    ),
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        border: OutlineInputBorder(),
                        labelText: 'Appointment name',
                        labelStyle: TextStyle(
                            color: Colors.purpleAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.bold
                        )

                    ),
                    textInputAction: TextInputAction.next,
                    focusNode: _appointmentNameNode,
                  ),
                  SizedBox(
                    height: 70,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                              _selectedDate == null ?
                              'No Date selected' :
                              'Appointment date: ${DateFormat.yMd().format(_selectedDate!)}'
                          ),
                        ),
                        FlatButton(onPressed: _displayDatePicker,
                            textColor: Theme.of(context).primaryColor,
                            child: const Text('Select date', style: TextStyle(fontWeight: FontWeight.bold),)),
                      ],
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {},
                    child: const Text('Book'),
                    textColor: Theme.of(context).textTheme.button!.color,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),

          ]
      ),
    );
  }
}
