import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uber_driver_app/Models/drivers.dart';

import 'Models/allUsers.dart';

String mapKey = "AIzaSyBU7G7vmeJ2MKnLqDLHj9ATpAupSDRpb0o";

User? firebaseUser;

Users? userCurrentInfo;

User? currentfirebaseUser;

StreamSubscription<Position>? homeTabPageStreamSubscription;

StreamSubscription<Position>? rideStreamSubscription;

final assetsAudioPlayer = AssetsAudioPlayer();

late Position currentPosition;

Drivers? driversInformation;
