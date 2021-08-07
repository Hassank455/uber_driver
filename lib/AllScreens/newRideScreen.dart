import 'package:flutter/material.dart';
import 'package:uber_driver_app/Models/rideDetails.dart';

class NewRideScreen extends StatefulWidget {

  final RideDetails? rideDetails;

  NewRideScreen({this.rideDetails});

  @override
  _NewRideScreenState createState() => _NewRideScreenState();
}

class _NewRideScreenState extends State<NewRideScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Ride"),
      ),
      body: Center(
        child: Text('this is New Ride Page'),
      ),
    );
  }
}
