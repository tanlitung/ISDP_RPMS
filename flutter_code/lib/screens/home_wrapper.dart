import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:isdp/models/app_user.dart';
import 'package:isdp/screens/authenticate/authenticate.dart';
import 'package:isdp/screens/home/doctor_home.dart';
import 'package:isdp/screens/home/patient_home.dart';
import 'package:isdp/services/database.dart';
import 'package:isdp/shared/loading.dart';
import 'package:isdp/shared/settings_page.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:isdp/globals.dart' as globals;

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({Key? key}) : super(key: key);

  @override
  _HomeWrapperState createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {

  bool redraw = true;

  final userDbRef = FirebaseDatabase.instance.ref("${DateTime.now().toString().substring(0, 10)}/");
  late StreamSubscription userDbStream;

  @override
  void initState() {
    super.initState();
    _activateListeners();
  }

  void _activateListeners() {
    userDbStream = userDbRef.onValue.listen((event) {

      setState(() {
        globals.values = event.snapshot.value;

        if (globals.values != null) {
          List keys = globals.values.keys.toList();

          keys.sort((a, b) => a.compareTo(b));

          globals.timeList = [];
          globals.hrList = [];
          globals.spo2List = [];
          globals.tempList = [];
          globals.positionList = [];
          globals.locationList = [];

          keys.asMap().forEach((index, value) {
            if ((globals.values[value]['hr'] != null) & (globals.values[value]['spo2'] != null) & (globals.values[value]['temp'] != null) & (globals.values[value]['position'] != null)) {
              globals.timeList.add(DateTime.parse('${DateTime.now().toString().substring(0, 10)} $value'));
              globals.hrList.add(globals.values[value]['hr']);
              globals.spo2List.add(globals.values[value]['spo2']);
              globals.tempList.add(globals.values[value]['temp']);
              globals.positionList.add(globals.values[value]['position']);
              globals.batList.add(globals.values[value]['bat'] != null ? globals.values[value]['bat'] : 100);
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    final userData = Provider.of<UserData>(context);

    if (userData.uid == '') {
      return Loading();
    } else {
      if ((userData.register == true) & (userData.name != '')) {
        if (userData.position == 'doctor') {
          return DoctorHome();
        } else {
          return PatientHome();
        }
      } else {
        return SettingsPage();
      }
    }
  }

  @override
  void deactivate() {
    userDbStream.cancel();
    super.deactivate();
  }
}

