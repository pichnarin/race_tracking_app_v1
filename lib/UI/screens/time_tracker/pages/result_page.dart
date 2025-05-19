// UI/screens/time_tracker/pages/result_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app_v1/UI/provider/time_tracker_provider.dart';
import 'package:race_tracking_app_v1/UI/theme/app_color.dart';
import 'package:race_tracking_app_v1/data/DTO/races_dto.dart';
import '../../../widget/manager/race_card.dart';
import '../../manager/result_detail_creen.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TimeTrackerProvider>(context, listen: false).loadRaces();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeTrackerProvider = Provider.of<TimeTrackerProvider>(context);
    final filteredRaces = timeTrackerProvider.filteredCompletedRaces; // Now returns List<RaceDTO>

    return Scaffold(
      body: timeTrackerProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => timeTrackerProvider.loadRaces(),
              child: ListView.builder(
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
                    // Search
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          TextField(
                            controller: searchController,
                            onChanged: timeTrackerProvider.updateSearch,
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
                                        timeTrackerProvider.updateSearch('');
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Race cards
                  final race = filteredRaces[index - 2];
                  final raceDate = "${_formatMonthDay(race.startTime)}, ${race.startTime.year}";
                  final totalParticipants = race.segments.length; // Using segments as proxy for participants

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: RaceCard(
                      raceName: race.name,
                      raceDate: raceDate,
                      totalParticipants: "$totalParticipants participants",
                      raceStatus: race.status.name.capitalize(),
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