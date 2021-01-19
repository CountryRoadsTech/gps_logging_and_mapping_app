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
      home: Scaffold(
        appBar: AppBar(
          title: Text('GPS Logging and Mapping'),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Your Current Location:',
              ),
              UserLocation(),
            ],
          ),
        ),
      )
      );
  }
}

class UserLocation extends StatefulWidget {
  @override
  _UserLocationState createState() => _UserLocationState();
}

class _UserLocationState extends State<UserLocation> {
  Position _userLocation;

  void setupLocationStream() {
    Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high).listen((Position position) {
      setState(() {
        _userLocation = position;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    setupLocationStream();
    return Text('$_userLocation');
  }
}
