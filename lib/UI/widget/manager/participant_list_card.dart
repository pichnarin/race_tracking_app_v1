import 'package:flutter/material.dart';

class ParticipantListCard extends StatelessWidget {
  final String bib;
  final String name;
  final String time;

  const ParticipantListCard({
    super.key,
    required this.bib,
    required this.name,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(bib)),
          Expanded(flex: 3, child: Text(name)),
          Expanded(flex: 2, child: Text(time, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class ParticipantListHeader extends StatelessWidget {
  const ParticipantListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text("Bib", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text("Participant", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("Time", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
