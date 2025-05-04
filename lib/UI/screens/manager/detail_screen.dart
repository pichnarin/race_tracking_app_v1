import 'package:flutter/material.dart';
import '../../widget/participants_table.dart';

class RaceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> raceData;

  const RaceDetailScreen({super.key, required this.raceData});
  
  @override
  Widget build(BuildContext context) {

    // final participants = raceData['participants'];
    // Convert participants map to a list
    final participants = (raceData['participants'] as Map<String, dynamic>)
        .values
        .map((participant) => participant as Map<String, dynamic>)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(raceData['name'] ?? 'Race Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // child: Text("Details for race: ${raceData.toString()}"),
        child: ParticipantTable(participants: participants)
      ),
    );
  }
}
