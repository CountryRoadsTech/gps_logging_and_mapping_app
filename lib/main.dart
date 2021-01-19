import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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
  Position _currentUserLocation;
  final _userLocationHistory = <Position>[];

  final _biggerFont = TextStyle(fontSize: 18.0);

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

  void setupLocationStream() {
    Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high).listen((Position position) {
      setState(() {
        _currentUserLocation = position;
        _userLocationHistory.add(_currentUserLocation);
      });
    });
  }

  Widget _buildList() {
    return ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;

          if (index < _userLocationHistory.length) {
            return _buildRow(_userLocationHistory[index]);
          }
        });
  }

  Widget _buildRow(Position location) {
    return ListTile(
      title: Text(
        '$location',
        style: _biggerFont,
      ),
    );
  }
}
