import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:isdp/globals.dart' as globals;
import 'package:isdp/models/app_user.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart' as loc;

Future<loc.Position> _determinePosition() async {
  bool serviceEnabled;
  loc.LocationPermission permission;
  // loc.Geolocator geolocator = loc.Geolocator()..forceAndroidLocationManager = true;

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

class MapScreen extends StatefulWidget {
  final String name;
  const MapScreen(this.name);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  var lat = 4.382634266572372;
  var lng = 100.96791833326559;

  Set<Marker> _markers = {};

  late GoogleMapController _googleMapController;

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {

    if((widget.name == 'Tan Li Tung')) {
      // lat = double.parse(globals.locationList.last.toString().split(' ')[0]);
      // lng = double.parse(globals.locationList.last.toString().split(' ')[1]);

      try {
        lat = double.parse(globals.location.latitude.toString());
        lng = double.parse(globals.location.longitude.toString());
      } catch (e) {
        lat = 4.382634266572372;
        lng = 100.96791833326559;
      }


    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.grey[100],
        title: Text(
          'Location',
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
      body: GoogleMap(
        onMapCreated: (controller) {
          setState(() {
            _googleMapController = controller;
            if(widget.name == 'Tan Li Tung') {
              _markers.add(Marker(
                  markerId: MarkerId('Id-1'),
                  position: LatLng(lat, lng),
                  infoWindow: InfoWindow(
                      title: "Location",
                      snippet: "${lat.toStringAsFixed(4)} ${lng.toStringAsFixed(4)}"
                  )));
              _googleMapController.showMarkerInfoWindow(MarkerId('Id-1'));
            }
          });
        },
        markers: _markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(lat, lng),
          zoom: 18,
        ),
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          globals.location = await _determinePosition();
          setState(() {});
        },
        child: const Icon(Icons.location_searching_outlined),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
