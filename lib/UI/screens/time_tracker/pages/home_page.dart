// UI/screens/time_tracker/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app_v1/UI/provider/time_tracker_provider.dart';
import 'package:race_tracking_app_v1/UI/screens/time_tracker/pages/tracking_page.dart';
import 'package:race_tracking_app_v1/UI/theme/app_color.dart';
import 'package:race_tracking_app_v1/data/DTO/races_dto.dart';
import '../../../widget/manager/race_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TimeTrackerProvider>(context, listen: false).loadRaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeTrackerProvider = Provider.of<TimeTrackerProvider>(context);
    final activeRaces = timeTrackerProvider.activeRaces; // Now returns List<RaceDTO>

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 40,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: const BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Time Tracker",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ]
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: const [
                Text(
                  "Active Competitions",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (timeTrackerProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (activeRaces.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: Text(
                  "No active races available.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeRaces.length,
              itemBuilder: (context, index) {
                final race = activeRaces[index];
                final raceDate = "${_formatMonthDay(race.startTime)}, ${race.startTime.year}";
                final totalParticipants = race.segments.length; // Using segments as proxy for participants

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: RaceCard(
                    raceName: race.name,
                    raceDate: raceDate,
                    totalParticipants: "$totalParticipants participants",
                    raceStatus: StringCasingExtension(race.status.name).capitalize(),
                    onTap: () {
                      if (race.uid.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Missing race ID")),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrackingPage(
                            raceData: race,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

String _formatMonthDay(DateTime date) {
  return "${_getMonthAbbr(date.month)} ${date.day}";
}

String _getMonthAbbr(int month) {
  const months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];
  return months[month - 1];
}