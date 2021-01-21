import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

// Immediately create and run GPSLoggingAndMapping app.
void main() {
  runApp(GPSLoggingAndMapping());
}

// This widget is the root of your application.
class GPSLoggingAndMapping extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS Logging and Mapping',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.green,
      ),
      home: UserLocation(),
    );
  }
}

class UserLocation extends StatefulWidget {
  @override
  _UserLocationState createState() => _UserLocationState();
}

class _UserLocationState extends State<UserLocation> {
  LocationData _currentUserLocation; // User's location
  final _userLocationHistory =
      <LocationData>[]; // A History of all the user's locations since they have been using the app this session.

  final _biggerFont = TextStyle(fontSize: 18.0);
  final _listViewScrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    setupLocationStream();

    return Scaffold(
      appBar: AppBar(
        title: Text('GPS Logging and Mapping'),
      ),
      body: _buildList(),
    );
  }

  void setupLocationStream() async {
    Location locationServices = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    // Ensure location services are turned on.
    _serviceEnabled = await locationServices.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await locationServices.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Ask the user for permission for accessing their device.
    _permissionGranted = await locationServices.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await locationServices.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Once the phone has returned the location, save and update it.
    locationServices.onLocationChanged.listen((LocationData currentLocation) {
      _saveNewLocation(currentLocation);
    });
  }

  Widget _buildList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();

        final index = i ~/ 2;

        if (index < _userLocationHistory.length) {
          return _buildRow((index + 1), _userLocationHistory[index]);
        }
      },
      itemCount: _userLocationHistory.length,
      controller: _listViewScrollController,
    );
  }

  Widget _buildRow(int index, LocationData location) {
    ListTile row = ListTile(
      title: Text(
        '$index: ' + '$location',
        style: _biggerFont,
      ),
    );

    _listViewScrollController.animateTo(_listViewScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100), curve: Curves.easeOut);

    return row;
  }

  void _saveNewLocation(LocationData newLocation) {
    setState(() {
      _currentUserLocation = newLocation;
      _userLocationHistory.add(_currentUserLocation);
    });
  }
}
