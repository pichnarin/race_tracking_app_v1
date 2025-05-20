import 'package:flutter/material.dart';
import '../UI/widget/time_tracker/time_tracker_app.dart';
import 'package:provider/provider.dart';
import '../UI/provider/race_provider.dart';
// void main() {
//   runApp(
//     const MaterialApp(
      
//       home: TimeTrackerApp(),
//     ),
//   );
// }

void main(){
  runApp(
    ChangeNotifierProvider(
      create: (_) => RaceProvider()..fetchStartedRaces(),
      child: MaterialApp(
        home: TimeTrackerApp() ,
      )
    )
  );
}