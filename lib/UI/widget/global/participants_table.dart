import 'package:flutter/material.dart';

class ParticipantTable extends StatelessWidget {
  final List<Map<String, dynamic>> participants;

  const ParticipantTable({Key? key, required this.participants})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // allows horizontal scrolling
      child: DataTable(
        columns: const [
          DataColumn(
            label: Text(
              'BIB',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text('Participants', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows:
            participants.map((participant) {
              return DataRow(
                cells: [
                  DataCell(
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFF6581BF),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        participant['bib'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(participant['name'] ?? '')),
                  DataCell(Text(participant['totalTime'] ?? '')),
                ],
              );
            }).toList(),
      ),
    );
  }
}
