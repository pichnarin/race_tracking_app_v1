import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app_v1/UI/screens/manager/result_detail_creen.dart';
import 'package:race_tracking_app_v1/UI/widget/manager/participant_list_card.dart';
import 'package:race_tracking_app_v1/UI/widget/manager/race_detail_card.dart';
import '../../theme/app_color.dart';
import '../../widget/Form/add_participant.dart';
import '../../providers/race_provider.dart';

class RaceDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? raceData;

  const RaceDetailScreen({super.key, this.raceData});

  @override
  State<RaceDetailScreen> createState() => _RaceDetailScreenState();
}

class _RaceDetailScreenState extends State<RaceDetailScreen> {
  Map<String, dynamic>? currentRace;

  @override
  void initState() {
    super.initState();
    currentRace = widget.raceData;
    final raceId = currentRace?['uid'];
    if (raceId != null) {
      Provider.of<RaceProvider>(
        context,
        listen: false,
      ).fetchParticipants(raceId);
    }
  }

  bool allParticipantsFinished(List<Map<String, dynamic>> participants) {
    return participants.isNotEmpty &&
        participants.every((p) {
          final time = p['totalTime']?.toString().trim() ?? '';
          return time.isNotEmpty && time != '00:00:00';
        });
  }

  @override
  Widget build(BuildContext context) {
    final race = currentRace;
    if (race == null) {
      return const Scaffold(
        body: Center(child: Text("No race data available.")),
      );
    }

    final raceName = race['name'] ?? 'Unnamed Race';
    final raceId = race['uid'];
    final DateTime? startDateTime = DateTime.tryParse(race['startTime'] ?? '');
    final location = race['location'] ?? 'Unknown';
    final raceStatus = (race['status'] ?? 'unknown').toString().capitalize();

    final bool canStartRace =
        startDateTime != null &&
        DateTime.now().isAfter(startDateTime) &&
        raceStatus.toLowerCase() == 'upcoming';

    return Consumer<RaceProvider>(
      builder: (context, provider, child) {
        final participants = provider.participants;

        return Scaffold(
          body: SingleChildScrollView(
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
                              raceName,
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
                              await provider.endRace(raceId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Race completed successfully!'),
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
                      startTime: startDateTime ?? DateTime.now(),
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
                                              repo: provider.repo,
                                              raceId: raceId,
                                              onParticipantAdded: () {
                                                provider.fetchParticipants(
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
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          )
                        else
                          ...participants.map((participant) {
                            return ParticipantListCard(
                              bib: participant.bib,
                              name: participant.name,
                              time: participant.totalTime,
                            );
                          }).toList(),
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
                                  await provider.startRace(raceId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Race started successfully!',
                                      ),
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
              if (allParticipantsFinished(
                participants.map((p) => p.toJson()).toList(),
              ))
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
      },
    );
  }
}

// Utilities
extension StringCasingExtension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
