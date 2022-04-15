import 'package:flutter/material.dart';
import 'package:isdp/models/app_user.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:isdp/models/vital_data.dart';
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

class Temperature extends StatefulWidget {
  const Temperature({Key? key}) : super(key: key);

  @override
  _TemperatureState createState() => _TemperatureState();
}

class _TemperatureState extends State<Temperature> {

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);

    List<VitalDoubleData> data = [];
    var sum = 0.0;
    var average = 0.0;
    var min = 0.0;
    var max = 0.0;

    if ((globals.timeList != []) & (userData.name == 'Tan Li Tung')) {
      globals.timeList.asMap().forEach((index, value) {
        sum += double.parse(globals.tempList[index].toString());
        globals.tempList[index] = double.parse(globals.tempList[index].toString());
        data.add(VitalDoubleData(value, double.parse(globals.tempList[index].toString())));
      });

      average = (sum / globals.tempList.length);
      max = globals.tempList.reduce((curr, next) => curr > next? curr: next);
      min = globals.tempList.reduce((curr, next) => curr < next? curr: next);
    } else {
      data.add(VitalDoubleData(DateTime.parse('${DateTime.now().toString().substring(0, 10)} 00:00:00.000'), 0.0));
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.grey[100],
        title: Text(
          'Temperature',
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
              'Average Temperature',
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
                getInfo('Average', '${average.toStringAsFixed(1)} °C'),
                getInfo('High', '${max.toStringAsFixed(1)} °C'),
                getInfo('Low', '${min.toStringAsFixed(1)} °C'),
              ],
            ),
            SizedBox(height: 20.0),
            Divider(thickness: 1.5),
            SizedBox(height: 20.0),
            SfCartesianChart(
              onMarkerRender: (args) {
                if (data[args.pointIndex!].value > 37.5) {
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
                    dataSource: data,
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
    );
  }
}
