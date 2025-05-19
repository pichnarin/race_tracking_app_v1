// UI/screens/time_tracker/pages/tracking_page.dart
// ignore_for_file: unused_local_variable, avoid_print, use_build_context_synchronously, unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app_v1/UI/provider/time_tracker_provider.dart';
import 'package:race_tracking_app_v1/UI/provider/participant_provider.dart';
import 'package:race_tracking_app_v1/data/DTO/races_dto.dart';
import 'package:race_tracking_app_v1/data/DTO/participants_dto.dart';
import '../../../theme/app_color.dart';
import '../../manager/result_detail_creen.dart';

class TrackingPage extends StatefulWidget {
  final RaceDTO raceData;

  const TrackingPage({
    super.key,
    required this.raceData,
  });

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final Map<String, int> clickCounts = {};
  String? selectedBib;
  List<ParticipantDTO> participants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Use the participant provider to load participants for this race
      final participantProvider = Provider.of<ParticipantProvider>(context, listen: false);
      await participantProvider.loadParticipants(widget.raceData.uid);
      
      setState(() {
        participants = participantProvider.participants;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading participants: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void showLog(BuildContext context, String message) {
    print(message);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String getNextSegment(int count) {
    if (count == 0) return 'swimming';
    if (count == 1) return 'cycling';
    if (count == 2) return 'running';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final timeTrackerProvider = Provider.of<TimeTrackerProvider>(context);
    final race = widget.raceData;
    final raceName = race.name;
    final raceId = race.uid;
    final location = race.location;
    final startTime = race.startTime.toString();
    final status = race.status.name;

    // Check if all participants finished
    final bool allFinished = false; // This needs to be updated to use the new method
    // We'll need to implement a method to check if all participants have finished

    final int currentCount =
        selectedBib != null ? (clickCounts[selectedBib] ?? 0) : 0;
    final String currentSegment = getNextSegment(currentCount);

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
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
                    child: Center(
                      child: Text(
                        raceName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),

                  // Race Details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Location: $location"),
                        Text("Start Time: $startTime"),
                        Text("Status: $status"),
                        const SizedBox(height: 16),

                        const Text(
                          "Participants (Tap to select):",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),

                        // Horizontal List of Bib Numbers
                        SizedBox(
                          height: 60,
                          child: participants.isEmpty
                              ? const Center(child: Text("No participants found"))
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: participants.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final participant = participants[index];
                                    final bib = participant.bib;
                                    final isSelected = selectedBib == bib;

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedBib = bib;
                                        });
                                      },
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected ? Colors.blue : Colors.grey[300],
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? Colors.blueAccent
                                                    : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                        child: Text(
                                          bib,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.white : Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),

                        const SizedBox(height: 24),

                        // Segment Action
                        if (selectedBib != null) ...[
                          Text(
                            "🏃‍♂️ Selected Bib: $selectedBib",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Current Segment: ${currentSegment.isNotEmpty ? currentSegment.capitalize() : "All done!"}",
                          ),
                          const SizedBox(height: 12),
                          if (currentSegment.isNotEmpty) ...[
                            ElevatedButton(
                              onPressed: () async {
                                final now = DateTime.now();
                                try {
                                  await timeTrackerProvider.recordSegmentTime(
                                    raceId: raceId,
                                    bib: selectedBib!,
                                    segment: currentSegment,
                                    finishTime: now,
                                  );

                                  showLog(
                                    context,
                                    "✅ Recorded $currentSegment for bib $selectedBib",
                                  );

                                  setState(() {
                                    clickCounts[selectedBib!] = currentCount + 1;
                                  });
                                } catch (e) {
                                  showLog(
                                    context,
                                    "❌ Failed to record $currentSegment: $e",
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 32,
                                ),
                              ),
                              child: Text("Record ${currentSegment.capitalize()}"),
                            ),
                          ] else ...[
                            const Text(
                              "🎉 All Segments Recorded",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ] else ...[
                          const Text(
                            "⬅️ Tap a bib to begin tracking.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Extension method for capitalizing strings
extension StringCasing on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}