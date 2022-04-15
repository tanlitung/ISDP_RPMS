import 'package:flutter/material.dart';
import 'package:isdp/models/app_user.dart';
import 'package:isdp/screens/vitals/heart_rate.dart';
import 'package:isdp/screens/vitals/map.dart';
import 'package:isdp/screens/vitals/spo2.dart';
import 'package:isdp/screens/vitals/temperature.dart';
import 'package:isdp/services/auth.dart';
import 'package:isdp/services/database.dart';
import 'package:provider/provider.dart';
import "package:isdp/shared/string_extension.dart";
import 'package:isdp/globals.dart' as globals;
import 'package:geolocator/geolocator.dart' as loc;

Future<loc.Position> _determinePosition() async {
  bool serviceEnabled;
  loc.LocationPermission permission;

  serviceEnabled = await loc.Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    await loc.Geolocator.openLocationSettings();
    return Future.error('Location services are disabled.');
  }

  permission = await loc.Geolocator.checkPermission();
  if (permission == loc.LocationPermission.denied) {
    permission = await loc.Geolocator.requestPermission();
    if (permission == loc.LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == loc.LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await loc.Geolocator.getCurrentPosition(desiredAccuracy: loc.LocationAccuracy.best);
}

Widget getVital(IconData icon, Color color, String vital, String value) {
  return Container(
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(5),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 3)
          )
        ]
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10),
          Icon(
              icon,
              size: 40,
              color: color
          ),
          SizedBox(height: 10),
          Text(
              vital,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800]
              )
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500]
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    ),
  );
}

class PatientHome extends StatefulWidget {
  const PatientHome({Key? key}) : super(key: key);

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    print(DateTime.now().toString().substring(0, 10));

    return Scaffold(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good day,',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      '${userData.name}',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.battery_full_sharp,
                      color: userData.name == 'Tan Li Tung' ? ((globals.batList.toString() != '[]') ? (globals.batList.last <= 20 ? Colors.red : (globals.batList.last <= 60 ? Colors.orange : Colors.green)) : Colors.green) : Colors.green,
                      size: 32.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${userData.name == 'Tan Li Tung' ? (globals.batList.toString() != '[]' ? '${globals.batList.last.toString()} % (${(int.parse(globals.batList.last.toString()) * 1300 / 13210).toStringAsFixed(1)} h)' : '100 (9.8 h)') : 'N/A'}',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${userData.name == 'Tan Li Tung' ? (globals.batList.toString() != '[]' ? '${((100 - int.parse(globals.batList.last.toString())) / 100 * 1300).toStringAsFixed(0)} mAh Used' : '100') : 'N/A'}',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20.0),
            // Divider(thickness: 1.0),
            // SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  flex: 8,
                  child: GestureDetector(
                    child: getVital(Icons.favorite, Colors.red, 'Heart Rate', '${userData.name == 'Tan Li Tung' ? (globals.hrList.toString() != '[]' ? globals.hrList.last.toString() + ' BPM' : 'No Data') : 'No Data'}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Provider<UserData>.value(
                              value: userData,
                              child: HeartRate(),
                            )
                        ),
                      );
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => HeartRate()
                      //   ),
                      // );
                    },
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Container()
                ),
                Expanded(
                  flex: 8,
                  child: GestureDetector(
                    child: getVital(Icons.bloodtype, Colors.green, 'Blood Pressure', '${userData.bps == null ? 120 : userData.bps.toString()}/${userData.bpd == null ? 80 : userData.bpd.toString()} mmHg'),
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => Provider<UserData>.value(
                      //         value: userData,
                      //         child: BloodPressure(),
                      //       )
                      //   ),
                      // );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  flex: 8,
                  child: GestureDetector(
                    child: getVital(Icons.device_thermostat, Colors.blue, 'Temperature', '${userData.name == 'Tan Li Tung' ? (globals.tempList.toString() != '[]' ? globals.tempList.last.toStringAsFixed(1) + ' °C' : 'No Data') : 'No Data'}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Provider<UserData>.value(
                              value: userData,
                              child: Temperature(),
                            )
                        ),
                      );
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => Temperature()
                      //   ),
                      // );
                    },
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Container()
                ),
                Expanded(
                  flex: 8,
                  child: GestureDetector(
                    child: getVital(Icons.blur_on, Colors.orange, 'SPO₂', '${userData.name == 'Tan Li Tung' ? (globals.spo2List.toString() != '[]' ? globals.spo2List.last.toString() + ' %' : 'No Data') : 'No Data'}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Provider<UserData>.value(
                              value: userData,
                              child: SPO2(),
                            )
                        ),
                      );
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => SPO2()
                      //   ),
                      // );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  flex: 8,
                  child: GestureDetector(
                    child: getVital(Icons.directions_walk, Colors.amber, 'Position', '${userData.name == 'Tan Li Tung' ? (globals.positionList.toString() != '[]' ? globals.positionList.last.toString().capitalize(): 'No Data') : 'No Data'}'),
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => Provider<UserData>.value(
                      //         value: userData,
                      //         child: Temperature(),
                      //       )
                      //   ),
                      // );
                    },
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Container()
                ),
                Expanded(
                  flex: 8,
                  child: GestureDetector(
                    child: getVital(Icons.location_on, Colors.purple, 'Location', '${userData.name == 'Tan Li Tung' ? '4.38 100.97' : 'No Data'}'),
                    onTap: () async {
                      globals.location = await _determinePosition();
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => Provider<UserData>.value(
                      //         value: userData,
                      //         child: MapScreen(userData.name),
                      //       )
                      //   ),
                      // );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MapScreen(userData.name),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  }
}

