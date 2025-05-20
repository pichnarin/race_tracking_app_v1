import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app_v1/UI/providers/race_provider.dart';
import 'package:race_tracking_app_v1/UI/providers/tracking_provider.dart';
import 'package:race_tracking_app_v1/UI/widget/time_tracker/time_tracker_app.dart';
import 'package:race_tracking_app_v1/data/Firebase/fire_race_repo.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Create the FireRaceRepo first
        Provider<FireRaceRepo>(
          create: (_) => FireRaceRepo(),
        ),
        // Then create RaceProvider with the repo
        ChangeNotifierProxyProvider<FireRaceRepo, RaceProvider>(
          create: (context) => RaceProvider(Provider.of<FireRaceRepo>(context, listen: false)),
          update: (context, repo, previous) => previous ?? RaceProvider(repo),
        ),
        // Create TrackingProvider
        ChangeNotifierProvider(
          create: (_) => TrackingProvider(),
        ),
      ],
      child: const MaterialApp(
        home: TimeTrackerApp(),
      ),
    ),
  );
}