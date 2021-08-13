import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_driver_app/AllWidgets/progressDialog.dart';
import 'package:uber_driver_app/Assistants/assistantMethode.dart';
import 'package:uber_driver_app/Assistants/mapKitAssistant.dart';

import 'package:uber_driver_app/Models/rideDetails.dart';
import 'package:uber_driver_app/configMaps.dart';
import 'package:uber_driver_app/main.dart';

class NewRideScreen extends StatefulWidget {
  final RideDetails? rideDetails;

  NewRideScreen({this.rideDetails});

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _NewRideScreenState createState() => _NewRideScreenState();
}

class _NewRideScreenState extends State<NewRideScreen> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newRideGoogleMapController;

  Set<Marker> markersSet = Set<Marker>();
  Set<Circle> circleSet = Set<Circle>();
  Set<Polyline> polylineSet = Set<Polyline>();
  List<LatLng> polyLineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  double mapPaddingFromBottom = 0;
  var geoLocator = Geolocator();
  var locationOptions =
      LocationOptions(accuracy: LocationAccuracy.bestForNavigation);
  BitmapDescriptor? animatingMarkerIcon;
  Position? myPosition;
  String status = "accepted";
  String? durationRide;
  bool isRequestingDirection = false;
  String btnTitle = "Arrived";
  Color btnColor = Colors.blueAccent;
  Timer? timer;
  int durationCounter = 0;

  @override
  void initState() {
    super.initState();

    accepetRideRequest();
  }

  void createIconMarker() {
    if (animatingMarkerIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/images/052 car-android.png")
          .then((value) {
        animatingMarkerIcon = value;
      });
    }
  }

  void getRideLiveLocationUpdates() {
    LatLng oldPos = LatLng(0, 0);

    rideStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      myPosition = position;
      LatLng mPostion = LatLng(position.latitude, position.longitude);

      var rot = MapKitAssistant.getMarkerRotation(oldPos.latitude,
          oldPos.longitude, mPostion.latitude, mPostion.longitude);

      Marker animatingMarker = Marker(
        markerId: MarkerId("animating"),
        position: mPostion,
        icon: animatingMarkerIcon!,
        rotation: rot,
        infoWindow: InfoWindow(title: "Current Location"),
      );

      setState(() {
        CameraPosition cameraPosition =
            new CameraPosition(target: mPostion, zoom: 17);
        newRideGoogleMapController
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        markersSet
            .removeWhere((marker) => marker.markerId.value == "animating");
        markersSet.add(animatingMarker);
      });
      oldPos = mPostion;
      updateRideDetails();

      String rideRequestId = widget.rideDetails!.rider_request_id!;
      Map locMap = {
        "latitude": currentPosition.latitude.toString(),
        "longitude": currentPosition.longitude.toString(),
      };
      newRequestRef.child(rideRequestId).child("driver_location").set(locMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    createIconMarker();

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPaddingFromBottom),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: NewRideScreen._kGooglePlex,
            myLocationEnabled: true,
            polylines: polylineSet,
            markers: markersSet,
            circles: circleSet,
            onMapCreated: (GoogleMapController controller) async {
              _controllerGoogleMap.complete(controller);
              newRideGoogleMapController = controller;

              setState(() {
                mapPaddingFromBottom = 265.0;
              });

              var currentLatLng =
                  LatLng(currentPosition.latitude, currentPosition.longitude);
              var pickUpLatLng = widget.rideDetails!.pickup;

              await getPlaceDirection(currentLatLng, pickUpLatLng!);

              getRideLiveLocationUpdates();
            },
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 16.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              height: 270.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 18.0),
                child: Column(
                  children: [
                    Text(durationRide ?? '',
                        style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: "Brand Bold",
                            color: Colors.deepPurple)),
                    SizedBox(height: 6.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('Muhammed Ali',
                            style: TextStyle(
                                fontSize: 24.0, fontFamily: "Brand Bold")),
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Icon(Icons.phone_android),
                        ),
                      ],
                    ),
                    SizedBox(height: 26.0),
                    Row(
                      children: [
                        Image.asset("assets/images/pickicon.png",
                            height: 16.0, width: 16.0),
                        SizedBox(width: 18.0),
                        Expanded(
                          child: Container(
                            child: Text(
                              'Street#44',
                              style: TextStyle(fontSize: 18.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Image.asset("assets/images/desticon.png",
                            height: 16.0, width: 16.0),
                        SizedBox(width: 18.0),
                        Expanded(
                          child: Container(
                            child: Text(
                              'Street#88',
                              style: TextStyle(fontSize: 18.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 26.0),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: RaisedButton(
                        onPressed: () async {
                          if (status == "accepted") {
                            status = "arrived";
                            String rideRequestId =
                                widget.rideDetails!.rider_request_id!;
                            newRequestRef
                                .child(rideRequestId)
                                .child("status")
                                .set(status);

                            setState(() {
                              btnTitle = "Start Trip";
                              btnColor = Colors.purple;
                            });
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) =>
                                  ProgressDialog(message: "Please wait...."),
                            );
                            await getPlaceDirection(widget.rideDetails!.pickup!,
                                widget.rideDetails!.dropoff!);

                            Navigator.pop(context);
                          } else if (status == "arrived") {
                            status = "onride";
                            String rideRequestId =
                                widget.rideDetails!.rider_request_id!;
                            newRequestRef
                                .child(rideRequestId)
                                .child("status")
                                .set(status);

                            setState(() {
                              btnTitle = "End Trip";
                              btnColor = Colors.redAccent;
                            });

                            initTimer();
                          } else if (status == "onride") {
                            endTheTrip();
                          }
                        },
                        color: btnColor,
                        child: Padding(
                          padding: EdgeInsets.all(17.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                btnTitle,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Icon(Icons.directions_car,
                                  color: Colors.white, size: 26.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> getPlaceDirection(
      LatLng pickUpLatLng, LatLng dropOffLatLng) async {
    showDialog(
        context: context,
        builder: (context) => ProgressDialog(message: 'Please wait...'));

    var details = await AssistantMethod.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);

    Navigator.pop(context);

    print("this is Encoded points ::");
    print(details!.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints!);

    polyLineCoordinates.clear();

    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        polyLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polyLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newRideGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );

    Marker droopOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: dropOffLatLng,
      markerId: MarkerId("droopOffId"),
    );

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(droopOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.blueAccent,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
      circleId: CircleId("pickUpId"),
    );

    Circle dropOffLocCircle = Circle(
      fillColor: Colors.deepPurple,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
      circleId: CircleId("droopOffId"),
    );

    setState(() {
      circleSet.add(pickUpLocCircle);
      circleSet.add(dropOffLocCircle);
    });
  }

  void accepetRideRequest() {
    String rideRequestId = widget.rideDetails!.rider_request_id!;
    newRequestRef.child(rideRequestId).child("status").set("accepted");
    newRequestRef
        .child(rideRequestId)
        .child("driver_name")
        .set(driversInformation!.name);
    newRequestRef
        .child(rideRequestId)
        .child("driver_phone")
        .set(driversInformation!.phone);
    newRequestRef
        .child(rideRequestId)
        .child("driver_id")
        .set(driversInformation!.id);
    newRequestRef.child(rideRequestId).child("car_details").set(
        '${driversInformation!.car_color} - ${driversInformation!.car_model}');

    Map locMap = {
      "latitude": currentPosition.latitude.toString(),
      "longitude": currentPosition.longitude.toString(),
    };
    newRequestRef.child(rideRequestId).child("driver_location").set(locMap);
  }

  void updateRideDetails() async {
    if (isRequestingDirection == false) {
      isRequestingDirection = true;
      if (myPosition == null) {
        return;
      }

      var posLatLng = LatLng(myPosition!.latitude, myPosition!.longitude);
      LatLng? destinationLatLng;

      if (status == "accepted") {
        destinationLatLng = widget.rideDetails!.pickup;
      } else {
        destinationLatLng = widget.rideDetails!.dropoff;
      }

      var directionDetails = await AssistantMethod.obtainPlaceDirectionDetails(
          posLatLng, destinationLatLng!);
      if (directionDetails != null) {
        setState(() {
          durationRide = directionDetails.durationText;
        });
      }
      isRequestingDirection = false;
    }
  }

  void initTimer() {
    const interval = Duration(seconds: 1);
    timer = Timer.periodic(interval, (timer) {
      durationCounter = durationCounter + 1;
    });
  }

  endTheTrip() async {
    timer!.cancel();

    showDialog(
        context: context,
        builder: (context) => ProgressDialog(message: 'Please wait...'));

    var currentLatLng = LatLng(myPosition!.latitude, myPosition!.longitude);

    var directionDetails = await AssistantMethod.obtainPlaceDirectionDetails(
        widget.rideDetails!.pickup!, currentLatLng);

    Navigator.pop(context);

    int fareAmount = AssistantMethod.calculateFares(directionDetails!);

    String rideRequestId = widget.rideDetails!.rider_request_id!;
    newRequestRef.child(rideRequestId).child("fares").set(fareAmount.toString());
    newRequestRef.child(rideRequestId).child("status").set("ended");
    rideStreamSubscription!.cancel();
  }
}
