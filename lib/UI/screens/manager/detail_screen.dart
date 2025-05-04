import 'package:flutter/material.dart';

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

class ParticipantTable extends StatelessWidget {
  final List<Map<String, dynamic>> participants;

  const ParticipantTable({Key? key, required this.participants}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // allows horizontal scrolling
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Bib Number')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Time')),
        ],
        rows: participants.map((participant) {
          return DataRow(
            cells: [
              DataCell(Text(participant['bib'] ?? '')),
              DataCell(Text(participant['name'] ?? '')),
              DataCell(Text(participant['totalTime'] ?? '')),
            ],
          );
        }).toList(),
      ),
    );
  }
}
