// ignore_for_file: use_build_context_synchronously, unused_import

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app_v1/UI/provider/participant_provider.dart';
import 'package:race_tracking_app_v1/UI/provider/race_provider.dart';
import 'package:race_tracking_app_v1/UI/screens/manager/result_detail_creen.dart';
import 'package:race_tracking_app_v1/UI/widget/manager/participant_list_card.dart';
import 'package:race_tracking_app_v1/UI/widget/manager/race_detail_card.dart';
import 'package:race_tracking_app_v1/data/DTO/races_dto.dart';
import 'package:race_tracking_app_v1/data/DTO/participants_dto.dart';
import '../../theme/app_color.dart';
import '../../widget/Form/add_participant.dart';

class RaceDetailScreen extends StatefulWidget {
  final RaceDTO? raceData;

  const RaceDetailScreen({super.key, this.raceData});

  @override
  State<RaceDetailScreen> createState() => _RaceDetailScreenState();
}

class _RaceDetailScreenState extends State<RaceDetailScreen> {
  RaceDTO? currentRace;

  @override
  void initState() {
    super.initState();
    currentRace = widget.raceData;

    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentRace != null) {
        final raceId = currentRace!.uid;
        Provider.of<ParticipantProvider>(
          context,
          listen: false,
        ).loadParticipants(raceId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access providers
    final raceProvider = Provider.of<RaceProvider>(context);
    final participantProvider = Provider.of<ParticipantProvider>(context);

    // Get updated race data if available
    if (currentRace != null) {
      final updatedRace = raceProvider.getRaceById(currentRace!.uid);
      if (updatedRace != null) {
        currentRace = updatedRace;
      }
    }

    final race = currentRace;
    if (race == null) {
      return const Scaffold(
        body: Center(child: Text("No race data available.")),
      );
    }

    final raceName = race.name;
    final raceId = race.uid;
    final startDateTime = race.startTime;
    final location = race.location;
    final raceStatus = race.status.name.capitalize();

    final participants = participantProvider.participants; // Now returns List<ParticipantDTO>
    final bool canStartRace =
        DateTime.now().isAfter(startDateTime) &&
        raceStatus.toLowerCase() == 'upcoming';

    return Scaffold(
      body:
          participantProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 100.0),
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
                          color: AppColor.primary,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              tooltip: 'Back',
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  race.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                try {
                                  await raceProvider.endRace(raceId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Race completed successfully!',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.access_alarms_outlined,
                                color: Colors.white,
                              ),
                              tooltip: 'Complete Race',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: RaceDetailCard(
                          raceName: raceName,
                          startTime: startDateTime,
                          location: location,
                          raceStatus: raceStatus,
                        ),
                      ),
                      const SizedBox(height: 32),
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
                                  onPressed:
                                      raceStatus.toLowerCase() == 'upcoming'
                                          ? () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AddParticipantForm(
                                                  raceId: raceId,
                                                  onParticipantAdded: () {
                                                    participantProvider
                                                        .loadParticipants(
                                                          raceId,
                                                        );
                                                  },
                                                );
                                              },
                                            );
                                          }
                                          : null,
                                  icon: Icon(
                                    Icons.add,
                                    color:
                                        raceStatus.toLowerCase() == 'upcoming'
                                            ? Colors.black
                                            : Colors.grey,
                                  ),
                                  tooltip:
                                      raceStatus.toLowerCase() == 'upcoming'
                                          ? 'Add a new participant'
                                          : 'Cannot add participants after the race has started',
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
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              )
                            else
                              ...participants.map((participant) {
                                return ParticipantListCard(
                                  bib: participant.bib,
                                  name: participant.name,
                                  time: participant.totalTime,
                                );
                              }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      bottomSheet: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (raceStatus.toLowerCase() == 'upcoming')
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      canStartRace
                          ? () async {
                            try {
                              await raceProvider.startRace(raceId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Race started successfully!'),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                ),
                              );
                            }
                          }
                          : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Race'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          if (participantProvider.allParticipantsFinished())
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ResultDetailScreen(raceData: race),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('See Results'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Utilities
extension StringCasingExtension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

class ParticipantListHeader extends StatelessWidget {
  const ParticipantListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 50,
          child: Text("BIB", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        SizedBox(width: 16),
        Text("Time", style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}