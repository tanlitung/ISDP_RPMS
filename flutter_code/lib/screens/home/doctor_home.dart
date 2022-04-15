import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isdp/models/app_user.dart';
import 'package:isdp/models/patient.dart';
import 'package:isdp/services/auth.dart';
import 'package:isdp/services/database.dart';
import 'package:isdp/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isdp/screens/home/patient_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:isdp/globals.dart' as globals;
import 'dart:async';

class DoctorHome extends StatefulWidget {
  // const Home({Key? key}) : super(key: key);

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {

  // final userDbRef = FirebaseDatabase.instance.ref("${DateTime.now().toString().substring(0, 10)}/");
  // late StreamSubscription userDbStream;
  //
  // @override
  // void initState() {
  //   super.initState();
  //   _activateListeners();
  // }
  //
  // void _activateListeners() {
  //   userDbStream = userDbRef.onValue.listen((event) {
  //     print(DateTime.now().toString().substring(0, 10));
  //     setState(() {
  //       globals.values = event.snapshot.value;
  //       print(globals.values);
  //
  //       if (globals.values != null) {
  //         List keys = globals.values.keys.toList();
  //
  //         keys.sort((a, b) => a.compareTo(b));
  //
  //         globals.timeList = [];
  //         globals.hrList = [];
  //         globals.spo2List = [];
  //         globals.tempList = [];
  //         globals.positionList = [];
  //         globals.locationList = [];
  //
  //         keys.asMap().forEach((index, value) {
  //           if ((globals.values[value]['hr'] != null) & (globals.values[value]['spo2'] != null) & (globals.values[value]['temp'] != null) & (globals.values[value]['position'] != null) & (globals.values[value]['location'] != null)) {
  //             globals.timeList.add(DateTime.parse('${DateTime.now().toString().substring(0, 10)} $value'));
  //             globals.hrList.add(globals.values[value]['hr']);
  //             globals.spo2List.add(globals.values[value]['spo2']);
  //             globals.tempList.add(globals.values[value]['temp']);
  //             globals.positionList.add(globals.values[value]['position']);
  //             globals.locationList.add(globals.values[value]['location']);
  //           }
  //         });
  //       }
  //     });
  //   });
  // }

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    print(globals.values['2022-03-25']);

    final userData = Provider.of<UserData>(context);

    return StreamProvider<List<UserData>>.value(
      value: DatabaseService().users,
      initialData: [],
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.grey[700],
              ),
              onPressed: () async {
                await DatabaseService(uid: userData.uid).updateSingleUserData('register', false);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.grey[700],
              ),
              onPressed: () async {
                await _auth.signOut();
              },
            ),
            SizedBox(width: 20.0),
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good day,',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'Dr. ${userData.name}',
                style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 10.0),
              Divider(thickness: 1.0),
              SizedBox(height: 10.0),
              Text(
                'Patients Status',
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.grey[900],
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 200.0,
                  child: PatientList()
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  // @override
  // void deactivate() {
  //   userDbStream.cancel();
  //   super.deactivate();
  // }
}
