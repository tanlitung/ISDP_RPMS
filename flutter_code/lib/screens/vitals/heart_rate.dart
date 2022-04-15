import 'package:flutter/material.dart';
import 'package:isdp/models/app_user.dart';
import 'package:isdp/models/vital_data.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'dart:math';
import 'package:isdp/globals.dart' as globals;

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
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500]
              ),
            ),
          ],
        )
    ),
  );
}

class HeartRate extends StatefulWidget {
  const HeartRate({Key? key}) : super(key: key);

  @override
  _HeartRateState createState() => _HeartRateState();
}

class _HeartRateState extends State<HeartRate> {

  @override
  Widget build(BuildContext context) {

    final userData = Provider.of<UserData>(context);

    List<VitalIntData> data = [];
    var sum = 0;
    var average = 0;
    var min = 0;
    var max = 0;

    if ((globals.timeList != []) & (userData.name == 'Tan Li Tung')) {
      globals.timeList.asMap().forEach((index, value) {
        sum += int.parse(globals.hrList[index].toString());
        data.add(VitalIntData(value, globals.hrList[index]));
      });

      average = (sum / globals.hrList.length).round();
      max = globals.hrList.reduce((curr, next) => curr > next? curr: next);
      min = globals.hrList.reduce((curr, next) => curr < next? curr: next);
    } else {
      data.add(VitalIntData(DateTime.parse('${DateTime.now().toString().substring(0, 10)} 00:00:00.000'), 0));
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.grey[100],
        title: Text(
          'Heart Rate',
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
      body: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Average Heart Rate',
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
                getInfo('Average', '${average} BPM'),
                getInfo('High', '${max} BPM'),
                getInfo('Low', '${min} BPM'),
              ],
            ),
            SizedBox(height: 20.0),
            Divider(thickness: 1.5),
            SizedBox(height: 20.0),
            SfCartesianChart(
                onMarkerRender: (args) {
                  if ((data[args.pointIndex!].value > 100) | (data[args.pointIndex!].value < 60)) {
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
                      dataSource: data,
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
          ],
        ),
      ),
    );
  }
}
