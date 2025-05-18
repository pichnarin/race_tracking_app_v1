import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app_v1/UI/theme/app_color.dart';
import 'package:race_tracking_app_v1/UI/widget/manager/feature_race_card.dart';
import 'package:race_tracking_app_v1/UI/widget/manager/race_card.dart';
import 'package:race_tracking_app_v1/UI/widget/manager/upcoming_race_card.dart';
import '../../../data/model/races.dart';
import '../../providers/race_provider.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onViewAllPressed;

  const HomeScreen({super.key, required this.onViewAllPressed});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentRaceIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<RaceProvider>(context, listen: false);
    provider.fetchRaces();
    _startRaceRotation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRaceRotation() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      final provider = Provider.of<RaceProvider>(context, listen: false);
      final upcomingRaces =
          provider.races
              .where((race) => race.status == RaceStatus.upcoming)
              .toList();

      if (upcomingRaces.isNotEmpty) {
        setState(() {
          _currentRaceIndex = (_currentRaceIndex + 1) % upcomingRaces.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RaceProvider>(
      builder: (context, provider, child) {
        final upcomingRaces =
            provider.races
                .where((race) => race.status == RaceStatus.upcoming)
                .toList();
        final recentRaces =
            provider.races
                .toList();

        return provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Race Manager",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Track and manage your race competitions.",
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        upcomingRaces.isNotEmpty
                            ? UpcomingRaceCard(
                              raceName: upcomingRaces[_currentRaceIndex].name,
                              raceDate:
                                  upcomingRaces[_currentRaceIndex].startTime
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0],
                              icon: Icons.directions_run,
                            )
                            : const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "Feature Races",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (upcomingRaces.isNotEmpty)
                    FeatureRaceCard(
                      image: 'https://via.placeholder.com/150',
                      raceName: upcomingRaces[_currentRaceIndex].name,
                      raceDate:
                          upcomingRaces[_currentRaceIndex].startTime
                              .toLocal()
                              .toString()
                              .split(' ')[0],
                      icon: Icons.directions_run,
                      totalParticipants:
                          (upcomingRaces[_currentRaceIndex]
                                      .participants
                                      ?.length ??
                                  0)
                              .toString(),
                      time: upcomingRaces[_currentRaceIndex].startTime
                          .toLocal()
                          .toString()
                          .split(' ')[1]
                          .substring(0, 5),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => RaceDetailScreen(
                                  raceData:
                                      upcomingRaces[_currentRaceIndex].toJson(),
                                ),
                          ),
                        );
                      },
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Text(
                          "Recent Competitions",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: widget.onViewAllPressed,
                          child: const Text(
                            "View All ▷",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (recentRaces.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          recentRaces.length,
                      itemBuilder: (context, index) {
                        final race = recentRaces[index];
                        final raceDate = _formatMonthDay(race.startTime);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: RaceCard(
                            raceName: race.name,
                            raceDate: "$raceDate, ${race.startTime.year}",
                            totalParticipants:
                                (race.participants?.length ?? 0).toString(),
                            raceStatus:
                                StringCasingExtension(
                                  race.status.name,
                                ).capitalize(),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => RaceDetailScreen(
                                        raceData: race.toJson(),
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
      },
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
