import 'package:flutter/material.dart';
import 'package:race_tracking_app_v1/UI/screens/time_tracker/pages/tracking_page.dart';
import 'package:race_tracking_app_v1/UI/theme/app_color.dart';
import 'dart:async';
import '../../../../data/firebase/fire_race_repo.dart';
import '../../../../data/model/races.dart';
import '../../../widget/manager/race_card.dart';
import '../../manager/detail_screen.dart';


class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
              children: [
                const Text(
                  "Recent Competitions",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (_raceList.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _raceList.length,
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

                    onTap: () {
                      final raceId = race['uid']; // Make sure 'uid' exists
                      if (raceId == null) {
                        // Optional safeguard
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
                            recordSegmentTime: ({
                              required String raceId,
                              required String bib,
                              required String segment,
                              required DateTime finishTime,
                            }) {
                              return _raceRepo.recordSegmentTime(
                                raceId: raceId,
                                bib: bib,
                                segment: segment,
                                finishTime: finishTime,
                              );
                            },
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
