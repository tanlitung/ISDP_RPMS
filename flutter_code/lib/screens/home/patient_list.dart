import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isdp/models/app_user.dart';
import 'package:isdp/models/patient.dart';
import 'package:isdp/screens/home/patient_tile.dart';
import 'package:provider/provider.dart';
import 'package:isdp/services/database.dart';

class PatientList extends StatefulWidget {
  const PatientList({Key? key}) : super(key: key);

  @override
  _PatientListState createState() => _PatientListState();
}

class _PatientListState extends State<PatientList> {
  @override
  Widget build(BuildContext context) {

    final users = Provider.of<List<UserData>>(context);

    List<UserData> patients = [];
    users.forEach((user) {
      if (user.position == 'patient') {
        patients.add(user);
      }
    });

    return ListView.builder(
      itemCount: patients.length,
      itemBuilder: (context, index) {
        return PatientTile(patient: patients[index]);
      },
    );
  }
}
