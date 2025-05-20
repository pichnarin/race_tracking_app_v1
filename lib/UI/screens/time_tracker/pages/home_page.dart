import 'package:flutter/material.dart';
// import 'package:race_tracking_app_v1/UI/screens/time_tracker/pages/tracking_page.dart';
// import 'package:race_tracking_app_v1/UI/theme/app_color.dart';
// import 'dart:async';
// import '../../../../data/repo/firebase_race_repo.dart';
// import '../../../widget/manager/race_card.dart';
import '../../../provider/race_provider.dart';
import 'package:provider/provider.dart';

// class HomePage extends StatefulWidget {

//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final FireRaceRepo _raceRepo = FireRaceRepo();
//   List<Map<String, dynamic>> _raceList = [];
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _loadRaceList();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   Future<void> _loadRaceList() async {
//     try {
//       final race = await _raceRepo.fetchRaceDetails();
//       if (race.isNotEmpty) {
//         setState(() {
//           // Filter races to include only those with status 'started'
//           _raceList = race.where((r) => r['status']?.toLowerCase() == 'started').toList();
//         });
//       }
//     } catch (e) {
//       print('Error fetching race details: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.only(
//               top: 40,
//               left: 16,
//               right: 16,
//               bottom: 16,
//             ),
//             decoration: const BoxDecoration(
//               color: AppColor.primary,
//               borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const Text(
//                   "Time Tracker",
//                   style: TextStyle(fontSize: 20, color: Colors.white),
//                 ),
//                ]
//             ),
//           ),
//           const SizedBox(height: 16),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               children: [
//                 const Text(
//                   "Recent Competitions",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//           ),
//           if (_raceList.isEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Center(
//                 child: Text(
//                   "No races available.",
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//               ),
//             )
//           else
//             ListView.builder(
//               shrinkWrap: true,
//               itemCount: _raceList.length,
//               itemBuilder: (context, index) {
//                 final race = _raceList[index];
//                 final raceName = race['name'] ?? 'Unnamed Race';
//                 final DateTime? startTime = DateTime.tryParse(
//                   race['startTime'] ?? '',
//                 );
//                 final raceDate = startTime != null
//                     ? "${_formatMonthDay(startTime)}, ${startTime.year}"
//                     : 'Unknown';
//                 final totalParticipants =
//                     (race['participants'] as Map?)?.length ?? 0;
//                 final status = race['status'] ?? 'Unknown';

//                 return Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 4,
//                   ),
//                   child: RaceCard(
//                     raceName: raceName,
//                     raceDate: raceDate,
//                     totalParticipants: "$totalParticipants participants",
//                     raceStatus:
//                         StringCasingExtension(status.toString()).capitalize(),
//                     onTap: () {
//                       final raceId = race['uid'];
//                       if (raceId == null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text("Missing race ID")),
//                         );
//                         return;
//                       }

//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => TrackingPage(
//                             raceData: race,
//                             recordSegmentTime: ({
//                               required String raceId,
//                               required String bib,
//                               required String segment,
//                               required DateTime finishTime,
//                             }) {
//                               return _raceRepo.recordSegmentTime(
//                                 raceId: raceId,
//                                 bib: bib,
//                                 segment: segment,
//                                 finishTime: finishTime,
//                               );
//                             },
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }
// }

// extension StringCasingExtension on String {
//   String capitalize() =>
//       isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
// }

// String _formatMonthDay(DateTime date) {
//   return "${_getMonthAbbr(date.month)} ${date.day}";
// }

// String _getMonthAbbr(int month) {
//   const months = [
//     "Jan",
//     "Feb",
//     "Mar",
//     "Apr",
//     "May",
//     "Jun",
//     "Jul",
//     "Aug",
//     "Sep",
//     "Oct",
//     "Nov",
//     "Dec",
//   ];
//   return months[month - 1];
// }

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final raceProvider = Provider.of<RaceProvider>(context);

    if (raceProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (raceProvider.error != null) {
      return Center(child: Text(raceProvider.error!));
    }

    final races = raceProvider.startedRaces;

    if (races.isEmpty) {
      return const Center(child: Text('No started races available.'));
    }

    return ListView.builder(
      itemCount: races.length,
      itemBuilder: (context, index) {
        final race = races[index];
        return RaceCard(race: race);
      },
    );
  }
}

class RaceCard extends StatelessWidget {
  final Map<String, dynamic> race;

  const RaceCard({super.key, required this.race});

  @override
  Widget build(BuildContext context) {
    final title = race['title'] ?? 'Untitled';
    final date = race['date'] ?? 'Unknown Date';
    final location = race['location'] ?? 'Unknown Location';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Date: ${date.toString()}"),
            const SizedBox(height: 4),
            Text("Location: ${location.toString()}"),
          ],
        ),
      ),
    );
  }
}
