import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app_v1/UI/provider/race_provider.dart';
import 'package:race_tracking_app_v1/UI/theme/app_color.dart';
import 'package:race_tracking_app_v1/UI/widget/manager/feature_race_card.dart';
import 'package:race_tracking_app_v1/data/DTO/races_dto.dart';
import 'package:race_tracking_app_v1/model/races.dart';
import '../../widget/manager/race_card.dart';
import '../../widget/manager/upcoming_race_card.dart';

import 'dart:async';

import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onViewAllPressed;

  const HomeScreen({super.key, required this.onViewAllPressed});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentRaceIndex = 0;
  int _currentFeatureIndex = 0;
  Timer? _timer;
  List<Race> _upcomingRaces = [];

  @override
  void initState() {
    super.initState();

    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RaceProvider>(context, listen: false).loadRaces();
      _loadUpcomingRaces();
    });

    _startRaceRotation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadUpcomingRaces() async {
    try {
      final raceProvider = Provider.of<RaceProvider>(context, listen: false);
      final races = raceProvider.races; // Now returns List<RaceDTO>

      final upcomingRaces = races
          .where((race) => race.status.name.toLowerCase() == 'upcoming')
          .map((race) => race.toModel())
          .toList();

      if (upcomingRaces.isNotEmpty) {
        setState(() {
          _upcomingRaces = upcomingRaces;
        });
      }
    } catch (e) {
      print('Error fetching races: $e');
    }
  }

  void _startRaceRotation() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        if (_upcomingRaces.isNotEmpty) {
          _currentRaceIndex = (_currentRaceIndex + 1) % _upcomingRaces.length;
        }

        final raceProvider = Provider.of<RaceProvider>(context, listen: false);
        if (raceProvider.races.isNotEmpty) {
          _currentFeatureIndex =
              (_currentFeatureIndex + 1) % raceProvider.races.length;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final raceProvider = Provider.of<RaceProvider>(context);
    final races = raceProvider.races; // Now returns List<RaceDTO>

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
                _upcomingRaces.isNotEmpty
                    ? UpcomingRaceCard(
                      raceName: _upcomingRaces[_currentRaceIndex].name,
                      raceDate:
                          _upcomingRaces[_currentRaceIndex].startTime
                              .toLocal()
                              .toString()
                              .split(' ')[0],
                      icon: Icons.directions_run,
                    )
                    : raceProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                      "No upcoming races",
                      style: TextStyle(color: Colors.white),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Feature Races",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          if (races.isNotEmpty)
            Builder(
              builder: (context) {
                final race = races[_currentFeatureIndex];
                
                return FeatureRaceCard(
                  image: 'https://via.placeholder.com/150',
                  raceName: race.name,
                  raceDate: race.startTime.toLocal().toString().split(' ')[0],
                  icon: Icons.directions_run,
                  totalParticipants: '${race.segments.length}', // Using segments as proxy for participants
                  time: race.startTime.toLocal().toString().split(' ')[1].substring(0, 5),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RaceDetailScreen(raceData: race),
                      ),
                    );
                  },
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  "Recent Competitions",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          if (races.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: races.length > 3 ? 3 : races.length,
              itemBuilder: (context, index) {
                final race = races[index];
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RaceDetailScreen(raceData: race),
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