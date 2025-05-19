// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app_v1/UI/provider/participant_provider.dart';
import 'package:race_tracking_app_v1/data/DTO/races_dto.dart';
import 'package:race_tracking_app_v1/data/DTO/participants_dto.dart';

class ResultDetailScreen extends StatefulWidget {
  final RaceDTO? raceData;

  const ResultDetailScreen({super.key, this.raceData});

  @override
  State<ResultDetailScreen> createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends State<ResultDetailScreen> {
  @override
  void initState() {
    super.initState();
    
    // Load participants for this race when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.raceData != null) {
        final raceId = widget.raceData!.uid;
        Provider.of<ParticipantProvider>(context, listen: false).loadParticipants(raceId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final participantProvider = Provider.of<ParticipantProvider>(context);
    
    // Get participants from the provider
    List<ParticipantDTO> participants = participantProvider.participants
        .where((p) => p.totalTime != null && p.totalTime != '00:00:00')
        .toList();

    // Sort by totalTime ascending (fastest first)
    participants.sort((a, b) {
      final timeA = _parseDuration(a.totalTime);
      final timeB = _parseDuration(b.totalTime);
      return timeA.compareTo(timeB);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.raceData?.name ?? "Race Results"),
        backgroundColor: Colors.blue,
      ),
      body: participantProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : participants.isEmpty
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
                            offset: const Offset(0, 2),
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
                                  p.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text("Bib: ${p.bib}"),
                              ],
                            ),
                          ),
                          Text(
                            p.totalTime,
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