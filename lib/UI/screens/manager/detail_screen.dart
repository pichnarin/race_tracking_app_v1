import 'package:flutter/material.dart';
import 'package:race_tracking_app_v1/UI/widget/manager/participant_list_card.dart';
import 'package:race_tracking_app_v1/UI/widget/manager/race_detail_card.dart';
import '../../widget/Form/add_participant.dart';
import '../../widget/global/participants_table.dart';
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
    final raceId = race['uid'];
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

    final participantsMap = (race['participants'] as Map?)?.cast<String, dynamic>() ?? {};
    final participants = participantsMap.isNotEmpty
        ? participantsMap.values
            .map<Map<String, dynamic>>((p) => p as Map<String, dynamic>)
            .toList()
        : [];

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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        tooltip: 'Back',
                      ),
                    ),
                    Center(
                      child: Text(
                        race['name'] ?? "Race Details",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // race Detail Card
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

              //participant List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Participants",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            letterSpacing: 1.1,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Show Add Participant dialog when the button is pressed
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AddParticipantForm(
                                  repo: _raceRepo, // Pass the repository for adding participants
                                  raceId: raceId, // Pass
                                  onParticipantAdded: () {
                                    loadRaceList(); // Refresh the participant list
                                  },
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.add, color: Colors.black),
                          tooltip: 'Add a new participant',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const ParticipantListHeader(),
                    const Divider(thickness: 1.5),
                    const SizedBox(height: 8),

                    if (participants.isEmpty)
                      const Text(
                        "No participants yet.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      )
                    else
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
