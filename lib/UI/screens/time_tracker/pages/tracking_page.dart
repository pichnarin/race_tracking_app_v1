// import 'package:flutter/material.dart';
// import '../../../widget/time_tracker/segments_widget.dart';
// import '../segments/cycling_segment.dart';
// import '../segments/running_segment.dart';
// import '../segments/swim_segment.dart';
//
// void main() {
//   runApp(MaterialApp(home: TrackingPage()));
// }
//
// class TrackingPage extends StatefulWidget {
//   const TrackingPage({super.key});
//
//   @override
//   State<TrackingPage> createState() => _TrackingPageState();
// }
//
// class _TrackingPageState extends State<TrackingPage> {
//   String selectedSegment = "swimming";
//
//   String getSegmentImage() {
//     switch (selectedSegment) {
//       case "cycling":
//         return 'assets/cycling.png';
//       case "running":
//         return 'assets/running.png';
//       case "swimming":
//       default:
//         return 'assets/swimming.png';
//     }
//   }
//
//   Widget getSegmentWidget() {
//     switch (selectedSegment) {
//       case "cycling":
//         return CyclingScreen(data: "Data for Cycling");
//       case "running":
//         return RunningScreen(data: "Data for Running");
//       case "swimming":
//       default:
//         return SwimmingScreen(data: "Data for Swimming");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [Image.asset(getSegmentImage(), width: 40, height: 40)],
//             ),
//             SizedBox(width: 10),
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   selectedSegment[0].toUpperCase() +
//                       selectedSegment.substring(1),
//                   style: TextStyle(fontSize: 18),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           SegmentSection(
//             selectedSegment: selectedSegment,
//             onSegmentSelected: (segment) {
//               setState(() {
//                 selectedSegment = segment;
//               });
//             },
//           ),
//
//           Expanded(child: getSegmentWidget()),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

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

  void showLog(BuildContext context, String message) {
    print(message);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final raceName = widget.raceData['name'] ?? 'Unnamed Race';
    final raceId = widget.raceData['uid'] ?? 'Unknown Race ID';
    final location = widget.raceData['location'] ?? 'Unknown Location';
    final startTime = widget.raceData['startTime'] ?? 'Unknown Start Time';
    final status = widget.raceData['status'] ?? 'Unknown Status';
    final participants =
        (widget.raceData['participants'] as Map?)?.values.toList() ?? [];
    final segments = widget.raceData['segments'] ?? {};

    return Scaffold(
      appBar: AppBar(title: Text(raceName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Location: $location"),
            Text("Start Time: $startTime"),
            Text("Status: $status"),
            const SizedBox(height: 16),
            const Text(
              "Segments:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...segments.entries.map((entry) {
              final segmentName = entry.key;
              final distance = entry.value['distance'] ?? 'Unknown Distance';
              return Text("$segmentName: $distance");
            }).toList(),
            const SizedBox(height: 16),
            const Text(
              "Participants:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  final participant = participants[index];
                  final bib = participant['bib'] ?? 'Unknown';
                  final name = participant['name'] ?? 'Unknown';
                  final totalTime = participant['totalTime'] ?? '00:00:00';

                  return Card(
                    child: ListTile(
                      title: Text("Bib: $bib - $name"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Time: $totalTime"),
                          ElevatedButton(
                            onPressed: () async {
                              final now = DateTime.now();
                              final count = clickCounts[bib] ?? 0;

                              String segment;
                              if (count == 0) {
                                segment = 'swimming';
                              } else if (count == 1) {
                                segment = 'cycling';
                              } else if (count == 2) {
                                segment = 'running';
                              } else {
                                showLog(
                                  context,
                                  'All segments recorded for $name',
                                );
                                return;
                              }

                              try {
                                await widget.recordSegmentTime(
                                  raceId: raceId,
                                  bib: bib,
                                  segment: segment,
                                  finishTime: now,
                                );

                                showLog(
                                  context,
                                  'Recorded $segment time for $name',
                                );
                                setState(() {
                                  clickCounts[bib] = count + 1;
                                });
                              } catch (e) {
                                showLog(
                                  context,
                                  'Failed to record $segment: $e',
                                );
                              }
                            },
                            child: const Text("Record Finish Time"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

