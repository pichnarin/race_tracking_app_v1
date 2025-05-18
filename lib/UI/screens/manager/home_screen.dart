import 'package:flutter/material.dart';
import 'package:race_tracking_app_v1/UI/theme/app_color.dart';
import 'package:race_tracking_app_v1/UI/widget/manager/feature_race_card.dart';
import '../../../data/repo/firebase_race_repo.dart';
import '../../../model/races.dart';
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
  final FireRaceRepo _raceRepo = FireRaceRepo();
  List<Race> _upcomingRaces = [];
  List<Map<String, dynamic>> _raceDetails = [];
  List<Map<String, dynamic>> _raceList = [];
  int _currentRaceIndex = 0;
  int _currentFeatureIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadUpcomingRaces();
    _loadRaceDetails();
    _loadRaceList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadRaceList() async {
    try {
      final race = await _raceRepo.fetchRaceDetails();
      if (race.isNotEmpty) {
        setState(() {
          _raceList = race;
        });
      }
    } catch (e) {
      print('Error fetching race details: $e');
    }
  }

  Future<void> _loadRaceDetails() async {
    try {
      final raceDetails = await _raceRepo.fetchRaceDetails();
      if (raceDetails.isNotEmpty) {
        setState(() {
          _raceDetails = raceDetails;
        });
        _startRaceRotation();
      }
    } catch (e) {
      print('Error fetching race details: $e');
    }
  }

  Future<void> _loadUpcomingRaces() async {
    try {
      final races = await _raceRepo.fetchRaces();
      final upcomingRaces =
          races.values
              .where((race) => race.status == RaceStatus.upcoming)
              .toList();
      if (upcomingRaces.isNotEmpty) {
        setState(() {
          _upcomingRaces = upcomingRaces;
        });
        _startRaceRotation();
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
        if (_raceDetails.isNotEmpty) {
          _currentFeatureIndex =
              (_currentFeatureIndex + 1) % _raceDetails.length;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    : const CircularProgressIndicator(),
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
          if (_raceDetails.isNotEmpty)
            Builder(
              builder: (context) {
                final race = _raceDetails[_currentFeatureIndex];
                final raceName = race['name'] ?? 'Unnamed Race';

                final DateTime? startTime = DateTime.tryParse(
                  race['startTime'] ?? '',
                );
                final raceDate =
                    startTime != null
                        ? startTime.toLocal().toString().split(' ')[0]
                        : 'Unknown';

                final time =
                    startTime != null
                        ? startTime
                            .toLocal()
                            .toString()
                            .split(' ')[1]
                            .substring(0, 5)
                        : 'N/A';

                final totalParticipants =
                    (race['participants'] as Map?)?.length ?? 0;

                return FeatureRaceCard(
                  image: 'https://via.placeholder.com/150',
                  raceName: raceName,
                  raceDate: raceDate,
                  icon: Icons.directions_run,
                  totalParticipants: '$totalParticipants',
                  time: time,
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
          if (_raceList.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _raceList.length > 3 ? 3 : _raceList.length,
              itemBuilder: (context, index) {
                final race = _raceList[index];
                final raceName = race['name'] ?? 'Unnamed Race';
                final DateTime? startTime = DateTime.tryParse(
                  race['startTime'] ?? '',
                );
                final raceDate =
                    startTime != null
                        ? "${_formatMonthDay(startTime)}, ${startTime.year}"
                        : 'Unknown';
                final totalParticipants =
                    (race['participants'] as Map?)?.length ?? 0;
                final status = race['status'] ?? 'Unknown';

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: RaceCard(
                    raceName: raceName,
                    raceDate: raceDate,
                    totalParticipants: "$totalParticipants participants",
                    raceStatus:
                        StringCasingExtension(status.toString()).capitalize(),

                    //go to each race detail
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => RaceDetailScreen(raceData: race),
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
