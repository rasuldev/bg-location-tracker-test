import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
void backgroundCallback() {
  BackgroundLocationTrackerManager.handleBackgroundUpdated(
        (data) async {
          // do nothing
        },
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundLocationTrackerManager.initialize(
    backgroundCallback,
    config: const BackgroundLocationTrackerConfig(
      loggingEnabled: true,
      androidConfig: AndroidConfig(
        notificationIcon: 'explore',
        trackingInterval: Duration(seconds: 4),
        distanceFilterMeters: null,
      ),
      iOSConfig: IOSConfig(
        activityType: ActivityType.FITNESS,
        distanceFilterMeters: null,
        restartAfterKill: true,
      ),
    ),
  );

  runApp(MyApp());
}

@override
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var isTracking = false;

  @override
  void initState() {
    super.initState();
    _getTrackingStatus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log("BUILD");
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    MaterialButton(
                      child: const Text('Request location permission'),
                      onPressed: _requestLocationPermission,
                    ),
                    if (Platform.isAndroid) ...[
                      const Text(
                          'Permission on android is only needed starting from sdk 33.'),
                    ],
                    MaterialButton(
                      child: const Text('Start Tracking'),
                      onPressed: isTracking
                          ? null
                          : () async {
                        await BackgroundLocationTrackerManager
                            .startTracking();
                        setState(() => isTracking = true);
                      },
                    ),
                    MaterialButton(
                      child: const Text('Stop Tracking'),
                      onPressed: isTracking
                          ? () async {
                        await BackgroundLocationTrackerManager
                            .stopTracking();
                        setState(() => isTracking = false);
                      }
                          : null,
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getTrackingStatus() async {
    isTracking = await BackgroundLocationTrackerManager.isTracking();
    setState(() {});
  }

  Future<void> _requestLocationPermission() async {
    final result = await Permission.location.request();
    if (result == PermissionStatus.granted) {
      print('GRANTED'); // ignore: avoid_print
    } else {
      print('NOT GRANTED'); // ignore: avoid_print
    }
  }

  Future<void> _requestNotificationPermission() async {
    final result = await Permission.notification.request();
    if (result == PermissionStatus.granted) {
      print('GRANTED'); // ignore: avoid_print
    } else {
      print('NOT GRANTED'); // ignore: avoid_print
    }
  }


}


