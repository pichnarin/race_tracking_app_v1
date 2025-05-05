import 'package:flutter/material.dart';
import 'package:race_tracking_app_v1/UI/widget/manager/participant_list_card.dart';
import 'package:race_tracking_app_v1/UI/widget/manager/race_detail_card.dart';
import '../../../data/firebase/fire_race_repo.dart';

class RaceDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? raceData;

  const RaceDetailScreen({super.key, this.raceData});

  @override
  State<RaceDetailScreen> createState() => _RaceDetailScreenState();
}

class _RaceDetailScreenState extends State<RaceDetailScreen> {
  final FireRaceRepo _raceRepo = FireRaceRepo();
  List<Map<String, dynamic>> allRaces = [];

  @override
  void initState() {
    super.initState();
    loadRaceList();
  }

  Future<void> loadRaceList() async {
    try {
      final races = await _raceRepo.fetchRaceDetails();
      if (races.isNotEmpty) {
        setState(() {
          allRaces = races;
        });
      }
    } catch (e) {
      print('Error fetching race details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final race = widget.raceData;
    if (race == null) {
      return const Scaffold(
        body: Center(child: Text("No race data available.")),
      );
    }

    final raceName = race['name'] ?? 'Unnamed Race';
    final DateTime? startDateTime = DateTime.tryParse(race['startTime'] ?? '');
    final raceDate =
        startDateTime != null
            ? "${_formatMonthDay(startDateTime)}, ${startDateTime.year}"
            : 'Unknown Date';

    final startTime =
        startDateTime != null
            ? "${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}"
            : 'Unknown Time';

    final location = race['location'] ?? 'Unknown';
    final raceStatus = (race['status'] ?? 'unknown').toString().capitalize();

    final participantsMap = race['participants'] as Map<String, dynamic>? ?? {};
    final participants =
        participantsMap.values
            .map<Map<String, dynamic>>((p) => p as Map<String, dynamic>)
            .toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(
                  top: 40,
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Race Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ✅ Race Detail Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: RaceDetailCard(
                  raceName: raceName,
                  raceDate: raceDate,
                  startTime: startTime,
                  location: location,
                  raceStatus: raceStatus,
                ),
              ),

              const SizedBox(height: 32),

              // ✅ Participant List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Participants",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const ParticipantListHeader(),
                    const Divider(thickness: 1.5),
                    const SizedBox(height: 8),
                    ...participants.map((participant) {
                      final bib = participant['bib'] ?? '-';
                      final name = participant['name'] ?? 'Unknown';
                      final totalTime = participant['totalTime'] ?? '00:00:00';

                      return ParticipantListCard(
                        bib: bib.toString(),
                        name: name.toString(),
                        time: totalTime.toString(),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Utilities

extension StringCasingExtension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

String _formatMonthDay(DateTime date) {
  return "${_getMonthAbbr(date.month)} ${date.day}";
}

String _getMonthAbbr(int month) {
  const months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  return months[month - 1];
}
