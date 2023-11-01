import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../helpers/mapbox_handler.dart';
import '../main.dart';
import '../screens/home.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    initializeLocationAndSave();
  }

  Future<Position> locatePosition() async {
    await Geolocator.isLocationServiceEnabled();
    await Geolocator.requestPermission();
    await Geolocator.checkPermission();

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  void initializeLocationAndSave() async {
    // // Ensure all permissions are collected for Locations
    // Location location = Location();
    // bool? serviceEnabled;
    // PermissionStatus? permissionGranted;

    // debugPrint("\n\n local variables set \n\n");

    // serviceEnabled = await location.serviceEnabled();
    // if (!serviceEnabled) {
    //   debugPrint("\n\n location not enabled \n\n");
    //   serviceEnabled = await location.requestService();
    // }

    // permissionGranted = await location.hasPermission();
    // if (permissionGranted == PermissionStatus.denied) {
    //   debugPrint("\n\n permission denied \n\n");
    //   permissionGranted = await location.requestPermission();
    // }

    // Get the current user location
    Position locationData = await locatePosition();
    LatLng currentLocation =
        LatLng(locationData.latitude, locationData.longitude);

    debugPrint("\n\n got current location \n\n");

    // Get the current user address
    String currentAddress =
        (await getParsedReverseGeocoding(currentLocation))['place'];

    debugPrint("\n\n got current addr \n\n");

    // Store the user location in sharedPreferences
    sharedPreferences.setDouble('latitude', locationData.latitude!);
    sharedPreferences.setDouble('longitude', locationData.longitude!);
    sharedPreferences.setString('current-address', currentAddress);

    debugPrint("\n\n added it in the shared prefs \n\n");
    debugPrint("\n\n the next like should change page to home \n\n");

    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const Home()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.indigo,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.car_detailed,
            color: Colors.white,
            size: 120,
          ),
          Text(
            'Audible Maps',
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
