import 'package:flutter/material.dart';

class RaceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> raceData;

  const RaceDetailScreen({super.key, required this.raceData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(raceData['name'] ?? 'Race Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("Details for race: ${raceData.toString()}"),
      ),
    );
  }
}
