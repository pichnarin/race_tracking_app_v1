import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app_v1/UI/screens/time_tracker/pages/tracking_page.dart';
import 'package:race_tracking_app_v1/UI/theme/app_color.dart';
import '../../../providers/race_provider.dart';
import '../../../providers/tracking_provider.dart';
import '../../../widget/manager/race_card.dart';
import '../../../../data/model/races.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RaceProvider>(context, listen: false).fetchRaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final raceProvider = Provider.of<RaceProvider>(context);

    final activeRaces =
    raceProvider.races
        .where((r) => r.status == RaceStatus.started)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildSectionTitle("Recent Competitions"),
          if (raceProvider.isLoading)
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
                final raceDate =
                    "${_formatMonthDay(race.startTime)}, ${race.startTime.year}";
                final totalParticipants = race.participants?.length ?? 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: RaceCard(
                    raceName: race.name,
                    raceDate: raceDate,
                    totalParticipants: "$totalParticipants participants",
                    raceStatus:
                    StringCasingExtension(race.status.name).capitalize(),
                    onTap: () {
                      Provider.of<TrackingProvider>(
                        context,
                        listen: false,
                      ).reset();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => TrackingPage(
                            race: race,
                          ), // pass Race instance directly
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
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
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
