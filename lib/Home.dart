import 'dart:async';
import 'package:audible_maps_asu/SearchWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController googleMapController;
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};

  late Set<Marker> markersSet = {
    const Marker(
      markerId: MarkerId('lakeside_park'),
      position: LatLng(32.8284240447788, -96.8010946692594),
    ),
    const Marker(
      markerId: MarkerId('aquarium'),
      position: LatLng(32.7845126858013, -96.80515900833115),
    ),
    const Marker(
      markerId: MarkerId('university_hospital'),
      position: LatLng(32.79155578373443, -96.77746552465636),
    ),
    const Marker(
      markerId: MarkerId('zoo'),
      position: LatLng(32.74343301670828, -96.81628470752499),
    ),
  };

  Position currPos = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);

  void onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
    if (!_controller.isCompleted) {
      _controller.complete(controller);
    }
  }

  getDirections(Set<Marker> markers) async {
    List<LatLng> polylineCoordinates = [];
    List<PolylineWayPoint> polylineWayPoints = [];
    for (var i = 0; i < markers.length; i++) {
      polylineWayPoints.add(PolylineWayPoint(
          location:
              "${markersSet.toList()[i].position.latitude.toString()},${markersSet.toList()[i].position.longitude.toString()}",
          stopOver: true));
    }
// result gets little bit late as soon as in video, because package // send http request for getting real road routes
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyDwMmCOeplzxH8a5B4DrSa3esRZUSLNnKg", //GoogleMap ApiKey
      PointLatLng(markers.first.position.latitude,
          markers.first.position.longitude), //first added marker
      PointLatLng(markers.last.position.latitude,
          markers.last.position.longitude), //last added marker
// define travel mode driving for real roads
      travelMode: TravelMode.driving,
// waypoints is markers that between first and last markers        wayPoints: polylineWayPoints
    );
// Sometimes There is no result for example you can put maker to the // ocean, if results not empty adding to polylineCoordinates
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }

    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 4,
    );
    polylines[id] = polyline;
  }

  @override
  initState() {
    myLocButt();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: GestureDetector(
        onTap: () => showSearch(context: context, delegate: SearchHandler()),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Set Destination',
            hintStyle: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      )),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 100,
              child: DrawerHeader(child: Text("Audible Maps by ASU")),
            ),
            ListTile(
              title: const Text('Item 69'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GoogleMap(
                markers: markersSet,
                initialCameraPosition:
                    const CameraPosition(target: LatLng(0, 0), zoom: 13.5),
                zoomControlsEnabled: true,
                onMapCreated: onMapCreated,
                polylines: Set<Polyline>.of(polylines.values),
              ),
            ),
            Expanded(
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                children: [
                  TextButton(
                      onPressed: () async => await myLocButt(),
                      child: const Text("My Location")),
                  TextButton(onPressed: () {}, child: const Text("Around me")),
                  TextButton(
                      onPressed: () {}, child: const Text("Ahead of me")),
                  TextButton(
                      onPressed: () {}, child: const Text("Nearby Markers")),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<Position> locatePosition() async {
    await Geolocator.isLocationServiceEnabled();
    // await Geolocator.requestPermission();
    await Geolocator.checkPermission();

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    return position;
  }

  myLocButt() async {
    final GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(currPos.latitude, currPos.longitude), 18));
    currPos = await locatePosition();

    setState(() {
      markersSet.add(Marker(
        markerId: const MarkerId("Orgin"),
        position: LatLng(currPos.latitude, currPos.longitude),
        infoWindow: const InfoWindow(
          title: 'Current Position',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
      getDirections(markersSet);
    });
    // Debug info
    print(currPos.latitude);
    print(currPos.longitude);
    print(markersSet.last);
  }
}

// AIzaSyAt2DLZpEI1mmRUePWMz8qzts4A9Uzrh6E
