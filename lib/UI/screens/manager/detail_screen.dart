import 'package:flutter/material.dart';
import '../../widget/participants_table.dart';
import '../../../data/firebase/fire_race_repo.dart';

class RaceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> raceData;

  const RaceDetailScreen({super.key, required this.raceData});

  Future<void> _startRace(BuildContext context) async {

    final FireRaceRepo repo = FireRaceRepo();
    final raceId = raceData['uid'];
    if (raceId != null) {
      try {
        await repo.startRaceEvent(raceId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Race "${raceData['name']}" has started.')),
        );
        // Optionally, you might want to refresh the screen or update the UI
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start race: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Race ID is missing.')),
      );
    }
  }
  
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
        child: Column(
          children: [
            ParticipantTable(participants: participants),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _startRace(context),
              child: const Text('Start Race'),
            ),
          ],
        )),
    );
  }
}
