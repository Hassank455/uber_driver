import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber_driver_app/Assistants/requestAssistant.dart';
import 'package:uber_driver_app/DataHandler/appData.dart';
import 'package:uber_driver_app/Models/address.dart';
import 'package:uber_driver_app/Models/allUsers.dart';
import 'package:uber_driver_app/Models/directionDetails.dart';

import '../configMaps.dart';

class AssistantMethod {
  static Future<DirectionDetails?> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";

    var res = await RequestAssistant.getRequest(directionUrl);

    if (res == "failed") {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints =
        res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText =
        res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue =
        res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText =
        res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue =
        res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails) {
    //in terms USD
    double timeTraveledFare = (directionDetails.durationValue! / 60) * 0.20;
    double distanceTraveledFare =
        (directionDetails.distanceValue! / 1000) * 0.20;
    double totalFaresAmount = timeTraveledFare + distanceTraveledFare;

    //Local Currency
    // 1$ =160 RS
    //double totalLocalAmount = totalFaresAmount * 160;

    return totalFaresAmount.truncate();
  }

  static void disableHomeTabLiveLocationUpdates() {
    homeTabPageStreamSubscription!.pause();
    Geofire.removeLocation(currentfirebaseUser!.uid);
  }

  static void enableHomeTabLiveLocationUpdates() {
    homeTabPageStreamSubscription!.resume();
    Geofire.setLocation(currentfirebaseUser!.uid, currentPosition.latitude,
        currentPosition.longitude);
  }
}
