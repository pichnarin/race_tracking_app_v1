import 'package:flutter/material.dart';

class ResultDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? raceData;

  const ResultDetailScreen({super.key, this.raceData});

  @override
  Widget build(BuildContext context) {
    final participantsMap =
        (raceData?['participants'] as Map?)?.cast<String, dynamic>() ?? {};

    final List<Map<String, dynamic>> participants = participantsMap.values
        .map((e) => e as Map<String, dynamic>)
        .where((p) => p['totalTime'] != null && p['totalTime'] != '00:00:00')
        .toList();

    // Sort by totalTime ascending (fastest first)
    participants.sort((a, b) {
      final timeA = _parseDuration(a['totalTime']);
      final timeB = _parseDuration(b['totalTime']);
      return timeA.compareTo(timeB);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Race Results"),
        backgroundColor: Colors.blue,
      ),
      body: participants.isEmpty
          ? const Center(child: Text("No results to display."))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: participants.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final p = participants[index];
          final rank = index + 1;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  child: Text(rank.toString()),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("Bib: ${p['bib'] ?? '-'}"),
                    ],
                  ),
                ),
                Text(
                  p['totalTime'] ?? '--:--:--',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Duration _parseDuration(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return Duration.zero;
    final parts = timeStr.split(':').map(int.parse).toList();
    if (parts.length == 3) {
      return Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
    }
    return Duration.zero;
  }
}