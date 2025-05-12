import 'package:flutter/material.dart';
import 'package:race_tracking_app_v1/UI/theme/app_color.dart';
import '../../../data/firebase/fire_race_repo.dart';
import '../../widget/manager/race_card.dart';
import 'result_detail_creen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final FireRaceRepo _raceRepo = FireRaceRepo();
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> allRaces = [];
  List<Map<String, dynamic>> filteredRaces = [];
  String searchText = '';

  @override
  void initState() {
    super.initState();
    _loadRaceList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRaceList() async {
    try {
      final races = await _raceRepo.fetchRaceDetails();
      if (races.isNotEmpty) {
        setState(() {
          allRaces = races;
        });
        _applyFilters();
      }
    } catch (e) {
      print('Error fetching race details: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      filteredRaces = allRaces.where((race) {
        final name = (race['name'] ?? '').toString().toLowerCase();
        final status = (race['status'] ?? '').toString().toLowerCase();

        final matchesSearch = name.contains(searchText.toLowerCase());
        final isCompleted = status == 'completed';

        return matchesSearch && isCompleted;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: filteredRaces.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Header
            return Container(
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
              decoration: const BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: const Center(
                child: Text(
                  "Results Dashboard",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            );
          }

          if (index == 1) {
            // Search and Filter
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Search
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            searchText = value;
                            _applyFilters();
                          },
                          decoration: InputDecoration(
                            hintText: "Search races...",
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                searchText = '';
                                _applyFilters();
                              },
                            )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            );
          }

          // Race cards
          final race = filteredRaces[index - 2];
          final raceName = race['name'] ?? 'Unnamed Race';
          final DateTime? startTime = DateTime.tryParse(race['startTime'] ?? '');
          final raceDate = startTime != null
              ? "${_formatMonthDay(startTime)}, ${startTime.year}"
              : 'Unknown';
          final totalParticipants = (race['participants'] as Map?)?.length ?? 0;
          final status = race['status'] ?? 'Unknown';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: RaceCard(
              raceName: raceName,
              raceDate: raceDate,
              totalParticipants: "$totalParticipants participants",
              raceStatus: status.toString().capitalize(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultDetailScreen(raceData: race),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
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
}

extension StringCasingExtension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
