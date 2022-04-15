import 'package:flutter/material.dart';
import 'package:isdp/models/app_user.dart';
import 'package:isdp/models/patient.dart';
import 'package:isdp/screens/home/patient_home.dart';
import 'package:isdp/screens/vitals_for_doctor.dart';
import 'package:isdp/globals.dart' as globals;

class PatientTile extends StatelessWidget {
  // const PatientTile({Key? key}) : super(key: key);

  final UserData patient;
  PatientTile({ required this.patient });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: InkWell(
        child: Card(
          // margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
          child: ListTile(
            leading: Icon(
              patient.gender == 'male' ? Icons.male : Icons.female,
              size: 40.0,
              color: patient.gender == 'male' ? Colors.blue : Colors.pink[300],
            ),
            title: Text(patient.name),
            subtitle: Text('${patient.name == 'Tan Li Tung' ? (globals.spo2List.last < 95 ? 'Patient SPO₂ Low!' : globals.tempList.last > 37.5 ? 'Patient Temp High!' : globals.hrList.last > 100 ? 'Patient Heart Rate High!' : 'Patient is healthy!') : 'No data'}'),
          )
        ),
        onTap: () {
          print(patient.uid);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VitalsForDoctor(patient.name, patient.uid)),
          );
        },
      ),
    );
  }
}
