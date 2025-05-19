// time_tracker_main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app_v1/UI/provider/segment_provider.dart';
import 'package:race_tracking_app_v1/UI/provider/time_tracker_provider.dart';
import '../UI/widget/time_tracker/time_tracker_app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimeTrackerProvider()),
        ChangeNotifierProvider(create: (_) => SegmentProvider()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TimeTrackerApp(),
      ),
    ),
  );
}