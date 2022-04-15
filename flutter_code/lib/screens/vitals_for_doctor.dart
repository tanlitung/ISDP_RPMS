import 'package:flutter/material.dart';
import 'package:isdp/models/vital_data.dart';
import 'package:isdp/screens/vitals/map.dart';
import 'package:isdp/services/local_notification_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:isdp/globals.dart' as globals;
import 'dart:async';
import "package:isdp/shared/string_extension.dart";
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

Widget getInfo(String info, String value) {
  return Expanded(
    flex: 3,
    child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              info,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              value,
              style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500]
              ),
            ),
          ],
        )
    ),
  );
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

class VitalsForDoctor extends StatefulWidget {
  final String name;
  final String uid;
  const VitalsForDoctor(this.name, this.uid);

  @override
  _VitalsForDoctorState createState() => _VitalsForDoctorState();
}

class _VitalsForDoctorState extends State<VitalsForDoctor> {

  @override
  Widget build(BuildContext context) {

    List<VitalIntData> hrData = [];
    var hrSum = 0;
    var hrAverage = 0;

    if (globals.timeList != []) {
      globals.timeList.asMap().forEach((index, value) {
        hrSum += int.parse(globals.hrList[index].toString());
        hrData.add(VitalIntData(value, globals.hrList[index]));
      });

      hrAverage = (hrSum / globals.hrList.length).round();
    } else {
      hrData.add(VitalIntData(DateTime.parse('${DateTime.now().toString().substring(0, 10)} 00:00:00.000'), 0));
    }

    List<VitalIntData> spo2Data = [];
    var spo2Sum = 0;
    var spo2Average = 0;

    if (globals.timeList != []) {
      globals.timeList.asMap().forEach((index, value) {
        spo2Sum += int.parse(globals.spo2List[index].toString());
        spo2Data.add(VitalIntData(value, globals.spo2List[index]));
      });

      spo2Average = (spo2Sum / globals.spo2List.length).round();
    } else {
      spo2Data.add(VitalIntData(DateTime.parse('${DateTime.now().toString().substring(0, 10)} 00:00:00.000'), 0));
    }

    List<VitalDoubleData> tempData = [];
    var tempSum = 0.0;
    var tempAverage = 0.0;

    if (globals.timeList != []) {
      globals.timeList.asMap().forEach((index, value) {
        tempSum += double.parse(globals.tempList[index].toString());
        globals.tempList[index] = double.parse(globals.tempList[index].toString());
        tempData.add(VitalDoubleData(value, double.parse(globals.tempList[index].toString())));
      });

      tempAverage = (tempSum / globals.tempList.length);
    } else {
      tempData.add(VitalDoubleData(DateTime.parse('${DateTime.now().toString().substring(0, 10)} 00:00:00.000'), 0.0));
    }

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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.grey[100],
        title: Text(
          widget.name,
          style: TextStyle(
              color: Colors.grey[800]
          ),
        ),
        leading: InkWell(
          child: Icon(
            Icons.arrow_back_outlined,
            color: Colors.grey[800],
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[100],
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Average Vital Readings',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 20.0),
              Divider(thickness: 1.5),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getInfo('HR', widget.name == 'Tan Li Tung' ? '$hrAverage BPM' : 'No Data'),
                  getInfo('SPO₂', widget.name == 'Tan Li Tung' ? '$spo2Average %' : 'No Data'),
                  getInfo('Temp', widget.name == 'Tan Li Tung' ? '${tempAverage.toStringAsFixed(1)} °C' : 'No Data'),
                  getInfo('BP', widget.name == 'Tan Li Tung' ? '120/80\nmmHg' : 'No Data'),
                ],
              ),
              SizedBox(height: 20.0),
              Divider(thickness: 1.5),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    flex: 8,
                    child: GestureDetector(
                      child: getVital(Icons.directions_walk, Colors.amber, 'Position', '${ widget.name == 'Tan Li Tung' ? (globals.positionList.toString() != '[]' ? globals.positionList.last.toString().capitalize(): 'No Data') : 'No Data'}'),
                      onTap: () {},
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Container()
                  ),
                  Expanded(
                    flex: 8,
                    child: GestureDetector(
                      child: getVital(Icons.location_on, Colors.purple, 'Location', '${ widget.name == 'Tan Li Tung' ? '4.38 100.97' : 'No Data'}'),
                      onTap: () async {
                        globals.position = await _determinePosition();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapScreen(widget.name),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Text(
                'Heart Rate',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.0),
              SfCartesianChart(
                  onMarkerRender: (args) {
                    if ((hrData[args.pointIndex!].value > 100) | (hrData[args.pointIndex!].value < 60)) {
                      print(args.pointIndex);
                      args.color = Colors.red;
                      args.markerHeight = 8;
                      args.markerWidth = 8;
                      args.shape = DataMarkerType.diamond;
                      args.borderColor = Colors.red;
                      args.borderWidth = 2;
                    }
                  },
                  // primaryXAxis: CategoryAxis(interval: 2),
                  primaryXAxis: DateTimeAxis(),
                  primaryYAxis: NumericAxis(
                    minimum: 50,
                    maximum: 110,
                  ),
                  // primaryXAxis: DateTimeAxis(interval: 2),
                  // Enable tooltip
                  tooltipBehavior: TooltipBehavior(enable: true),

                  // trackballBehavior: TrackballBehavior(enable: true),
                  series: <ChartSeries<VitalIntData, DateTime>>[
                    LineSeries<VitalIntData, DateTime>(
                      dataSource: widget.name == 'Tan Li Tung' ? hrData : [VitalIntData(DateTime.parse('${DateTime.now().toString().substring(0, 10)} 00:00:00.000'), 0)],
                      xValueMapper: (VitalIntData heart, _) => heart.time,
                      yValueMapper: (VitalIntData heart, _) => heart.value,
                      name: 'Heart Rate',
                      markerSettings: MarkerSettings(
                          isVisible: true,
                          height: 4,
                          width: 4,
                          borderColor: Colors.blue),
                    )
                  ]),
              SizedBox(height: 20.0),
              Text(
                'SPO₂',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.0),
              SfCartesianChart(
                  onMarkerRender: (args) {
                    if (spo2Data[args.pointIndex!].value < 95) {
                      print(args.pointIndex);
                      args.color = Colors.red;
                      args.markerHeight = 8;
                      args.markerWidth = 8;
                      args.shape = DataMarkerType.diamond;
                      args.borderColor = Colors.red;
                      args.borderWidth = 2;
                    }
                  },
                  // primaryXAxis: CategoryAxis(interval: 2),
                  primaryXAxis: DateTimeAxis(),
                  primaryYAxis: NumericAxis(
                    minimum: 85,
                    maximum: 105,
                  ),
                  // primaryXAxis: DateTimeAxis(interval: 2),
                  // Enable tooltip
                  tooltipBehavior: TooltipBehavior(enable: true),

                  // trackballBehavior: TrackballBehavior(enable: true),
                  series: <ChartSeries<VitalIntData, DateTime>>[
                    LineSeries<VitalIntData, DateTime>(
                      dataSource: widget.name == 'Tan Li Tung' ? spo2Data : [VitalIntData(DateTime.parse('${DateTime.now().toString().substring(0, 10)} 00:00:00.000'), 0)],
                      xValueMapper: (VitalIntData spo2, _) => spo2.time,
                      yValueMapper: (VitalIntData spo2, _) => spo2.value,
                      name: 'Heart Rate',
                      markerSettings: MarkerSettings(
                          isVisible: true,
                          height: 4,
                          width: 4,
                          borderColor: Colors.blue),
                    )
                  ]),
              SizedBox(height: 20.0),
              Text(
                'Temperature',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.0),
              SfCartesianChart(
                  onMarkerRender: (args) {
                    if (tempData[args.pointIndex!].value > 37.5) {
                      print(args.pointIndex);
                      args.color = Colors.red;
                      args.markerHeight = 8;
                      args.markerWidth = 8;
                      args.shape = DataMarkerType.diamond;
                      args.borderColor = Colors.red;
                      args.borderWidth = 2;
                    }
                  },
                  // primaryXAxis: CategoryAxis(interval: 2),
                  primaryXAxis: DateTimeAxis(),
                  primaryYAxis: NumericAxis(
                    minimum: 35,
                    maximum: 38,
                  ),
                  // primaryXAxis: DateTimeAxis(interval: 2),
                  // Enable tooltip
                  tooltipBehavior: TooltipBehavior(enable: true),

                  // trackballBehavior: TrackballBehavior(enable: true),
                  series: <ChartSeries<VitalDoubleData, DateTime>>[
                    LineSeries<VitalDoubleData, DateTime>(
                      dataSource: widget.name == 'Tan Li Tung' ? tempData : [VitalDoubleData(DateTime.parse('${DateTime.now().toString().substring(0, 10)} 00:00:00.000'), 0.0)],
                      xValueMapper: (VitalDoubleData temp, _) => temp.time,
                      yValueMapper: (VitalDoubleData temp, _) => temp.value,
                      name: 'Temperature',
                      markerSettings: MarkerSettings(
                          isVisible: true,
                          height: 4,
                          width: 4,
                          borderColor: Colors.blue),
                    )
                  ]),
            ],
          ),
        ),
      ),
    );
  }
}
