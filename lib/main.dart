import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  // A History of all the user's locations since they have been using the app this session.
  final _userLocationHistory = <LocationData>[];

  final _databaseName = 'gps_logging_and_mapping_app.db';
  final _databaseMigrationVersion = 1;
  Database _database; // Store the history to a local database, for later syncing to the server.

  final _remoteAPIURL = 'http://10.0.2.2:3000/points/'; // 10.0.2.2 == localhost for the android emulator.

  final _biggerFont = TextStyle(fontSize: 18.0);
  final _listViewScrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    _setupLocationStream();
    _setupDatabase();

    return Scaffold(
      appBar: AppBar(
        title: Text('GPS Logging and Mapping'),
      ),
      body: _buildList(),
    );
  }

  void _setupLocationStream() async {
    Location locationServices = new Location();
    locationServices.changeSettings(accuracy: LocationAccuracy.high); // Use highest location accuracy possible.

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // Ensure location services are turned on.
    _serviceEnabled = await locationServices.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await locationServices.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Ask the user for permission before accessing their device's location.
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
        if (i.isOdd) return Divider(); // Every other row should be a divider.

        final index = i ~/ 2;

        // Only access the location history list if the index is within range.
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
    _saveRecordToDatabase(_currentUserLocation);
    _postRecordToRemoteAPI(_currentUserLocation);
  }

  void _setupDatabase() async {
    _database = await openDatabase(_databaseName, version: _databaseMigrationVersion,
        onCreate: (Database db, int version) async {
      // When creating the database, create the table's for points.
      if (version == 1) {
        await db.execute(
            'CREATE TABLE points (id INTEGER PRIMARY KEY, name TEXT, comment TEXT, latitude REAL, longitude REAL, accuracy REAL, altitude REAL, speed REAL, heading REAL, recorded_at TEXT, point_of_interest INTEGER)');
      }
    });
  }

  void _saveRecordToDatabase(LocationData point) {
    _database.transaction((txn) async {
      var record = await txn.rawInsert(
          'INSERT INTO points(name, latitude, longitude, accuracy, altitude, speed, heading, recorded_at, point_of_interest) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            'point name *',
            point.latitude,
            point.longitude,
            point.accuracy,
            point.altitude,
            point.speed,
            point.heading,
            _convertToDateTime(point.time.toInt()),
            0
          ]);
    });
  }

  String _convertToDateTime(int time) {
    return DateTime.fromMillisecondsSinceEpoch(time).toString();
  }

  void _postRecordToRemoteAPI(LocationData point) async {
    var response = await http.post(_remoteAPIURL, body: jsonEncode({'point': {
      'name': 'idk test name?',
      'latitude': point.latitude.toString(),
      'longitude': point.longitude.toString(),
      'accuracy': point.accuracy.toString(),
      'altitude': point.altitude.toString(),
      'speed': point.speed.toString(),
      'heading': point.heading.toString(),
      'recorded_at': _convertToDateTime(point.time.toInt()),
      'point_of_interest': "0"
    }}));

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
  }
}
