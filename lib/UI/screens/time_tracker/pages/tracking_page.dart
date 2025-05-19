import 'package:flutter/material.dart';
import '../../../theme/app_color.dart';
import '../../manager/result_detail_screen.dart';

class TrackingPage extends StatefulWidget {
  final Map<String, dynamic> raceData;
  final Future<void> Function({
    required String raceId,
    required String bib,
    required String segment,
    required DateTime finishTime,
  })
  recordSegmentTime;

  const TrackingPage({
    super.key,
    required this.raceData,
    required this.recordSegmentTime,
  });

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final Map<String, int> clickCounts = {};
  String? selectedBib;

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

  bool allParticipantsFinished(List<Map<String, dynamic>> participants) {
    return participants.isNotEmpty &&
        participants.every((p) {
          final time = p['totalTime']?.toString().trim() ?? '';
          return time.isNotEmpty && time != '00:00:00';
        });
  }

  @override
  Widget build(BuildContext context) {
    final race = widget.raceData;
    final raceName = race['name'] ?? 'Unnamed Race';
    final raceId = race['uid'] ?? 'Unknown Race ID';
    final location = race['location'] ?? 'Unknown Location';
    final startTime = race['startTime'] ?? 'Unknown Start Time';
    final status = race['status'] ?? 'Unknown Status';

    final participantsMap =
        (race['participants'] as Map?)?.cast<String, dynamic>() ?? {};
    final participants =
        participantsMap.values.map((e) => e as Map<String, dynamic>).toList();

    // Check if all participants finished
    final bool allFinished = allParticipantsFinished(participants);

    final int currentCount =
        selectedBib != null ? (clickCounts[selectedBib] ?? 0) : 0;
    final String currentSegment = getNextSegment(currentCount);

    return Scaffold(
      body: SingleChildScrollView(
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
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: participants.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final participant = participants[index];
                        final bib = participant['bib'] ?? '---';
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
                              bib.toString(),
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
                            await widget.recordSegmentTime(
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

                  // Show "See Results" button if all participants finished
                  if (allFinished) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                              builder: (context) => ResultDetailScreen(raceData: race),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 32,
                          ),
                        ),
                        child: const Text("See Results",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),),
                      ),
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
