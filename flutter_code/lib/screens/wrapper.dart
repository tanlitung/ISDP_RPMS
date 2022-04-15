import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:isdp/models/app_user.dart';
import 'package:isdp/screens/authenticate/authenticate.dart';
import 'package:isdp/screens/home_wrapper.dart';
import 'package:isdp/services/database.dart';
import 'package:isdp/services/local_notification_service.dart';
import 'package:provider/provider.dart';
import 'package:isdp/globals.dart' as globals;

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

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

    final user = Provider.of<AppUser?>(context);

    if (globals.hrList.toString() != '[]') {
      if(globals.hrList.last > 100){
        LocalNotificationService.display('Alert', 'Tan Li Tung HR High');
      }
    }

    if (globals.spo2List.toString() != '[]') {
      if(globals.spo2List.last < 95){
        LocalNotificationService.display('Alert', 'Tan Li Tung SPO2 Low');
      }
    }

    if (globals.tempList.toString() != '[]') {
      if(globals.tempList.last > 37.5){
        LocalNotificationService.display('Alert', 'Tan Li Tung Temperature High');
      }
    }


    // final userDbRef = FirebaseDatabase.instance.ref("${DateTime.now().toString().substring(0, 10)}/");
    // late StreamSubscription userDbStream;
    //
    // userDbStream = userDbRef.onValue.listen((event) {
    //
    //   setState(() {
    //     globals.values = event.snapshot.value;
    //
    //     if (globals.values != null) {
    //       List keys = globals.values.keys.toList();
    //
    //       keys.sort((a, b) => a.compareTo(b));
    //
    //       globals.timeList = [];
    //       globals.hrList = [];
    //       globals.spo2List = [];
    //       globals.tempList = [];
    //       globals.positionList = [];
    //       globals.locationList = [];
    //
    //       keys.asMap().forEach((index, value) {
    //         if ((globals.values[value]['hr'] != null) & (globals.values[value]['spo2'] != null) & (globals.values[value]['temp'] != null) & (globals.values[value]['position'] != null) & (globals.values[value]['location'] != null)) {
    //           globals.timeList.add(DateTime.parse('${DateTime.now().toString().substring(0, 10)} $value'));
    //           globals.hrList.add(globals.values[value]['hr']);
    //           globals.spo2List.add(globals.values[value]['spo2']);
    //           globals.tempList.add(globals.values[value]['temp']);
    //           globals.positionList.add(globals.values[value]['position']);
    //           globals.locationList.add(globals.values[value]['location']);
    //         }
    //       });
    //     }
    //   });
    // });

    if (user == null) {
      return Authenticate();
    } else {
      return StreamProvider<UserData>.value(
        catchError: (_, err) {

          print('Error (wrapper.dart): $err');

          return UserData(
            uid: '',
            name: '',
            position: '',
            age: '',
            gender: '',
            data: {},
            register: false,
            height: 0,
            weight: 0,
            bps: 0,
            bpd: 0
          );
        },
        initialData: UserData(
          uid: '',
          name: '',
          position: '',
          age: '',
          gender: '',
          data: {},
          register: false,
          height: 0,
          weight: 0,
          bps: 0,
          bpd: 0
        ),
        value: DatabaseService(uid: user.uid).userData,
        child: HomeWrapper(),
      );
    }
  }

  @override
  void deactivate() {
    userDbStream.cancel();
    super.deactivate();
  }
}

