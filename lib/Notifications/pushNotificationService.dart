import 'dart:io' show Platform;

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_driver_app/Models/rideDetails.dart';
import 'package:uber_driver_app/Notifications/notificationDialog.dart';
import 'package:uber_driver_app/configMaps.dart';
import 'package:uber_driver_app/main.dart';

class PushNotificationService {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future initialize(context) async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage data: ${message.data}");
      retrieveRideRequestInfo(getRideRequestId(message.data),context);
    });

    firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      print('getInitialMessage data: ${message!.data}');
      retrieveRideRequestInfo(getRideRequestId(message.data),context);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('onMessageOpenedApp data: ${message.data}');
      retrieveRideRequestInfo(getRideRequestId(message.data),context);
    });
  }

  Future<String?> getToken() async {
    String? token = await firebaseMessaging.getToken();
    print("this is token :: ");
    print(token);
    driversRef.child(currentfirebaseUser!.uid).child("token").set(token);

    firebaseMessaging.subscribeToTopic("alldrivers");
    firebaseMessaging.subscribeToTopic("allusers");
  }

  String rideRequestId = '';

  String getRideRequestId(Map<String, dynamic> message) {
    if (Platform.isAndroid) {
     // rideRequestId = message['data']['ride_request_id'];
      rideRequestId = message['ride_request_id'];
    } else {
      rideRequestId = message['ride_request_id'];
    }
    return rideRequestId;
  }

  void retrieveRideRequestInfo(String rideRequestId, BuildContext context) {
    newRequestRef.child(rideRequestId).once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {

        assetsAudioPlayer.open(Audio("assets/sounds/alert.mp3"));
        assetsAudioPlayer.play();

        double pickUpLocationLat =
            double.parse(dataSnapshot.value['pickup']['latitude'].toString());
        double pickUpLocationLng =
            double.parse(dataSnapshot.value['pickup']['longitude'].toString());
        String pickUpAddress = dataSnapshot.value['pickup_address'].toString();

        double dropOffLocationLat =
            double.parse(dataSnapshot.value['dropoff']['latitude'].toString());
        double dropOffLocationLng =
            double.parse(dataSnapshot.value['dropoff']['longitude'].toString());
        String dropOffAddress =
            dataSnapshot.value['dropoff_address'].toString();

        String paymentMethod = dataSnapshot.value['payment_method'].toString();

        RideDetails rideDetails = RideDetails();
        rideDetails.rider_request_id = rideRequestId;
        rideDetails.pickup_address = pickUpAddress;
        rideDetails.dropoff_address = dropOffAddress;
        rideDetails.pickup = LatLng(pickUpLocationLat, pickUpLocationLng);
        rideDetails.dropoff = LatLng(dropOffLocationLat, dropOffLocationLng);
        rideDetails.payment_method = paymentMethod;

        print("Information :: ");
        print(rideDetails.pickup_address);
        print(rideDetails.dropoff_address);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) =>
              NotificationDialog(rideDetails: rideDetails),
        );
      }
    });
  }
}
