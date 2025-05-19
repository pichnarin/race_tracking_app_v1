import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app_v1/UI/provider/race_provider.dart';
import 'package:race_tracking_app_v1/UI/theme/app_color.dart';
import 'package:race_tracking_app_v1/data/DTO/races_dto.dart';
import '../../widget/manager/race_card.dart';
import 'result_detail_creen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RaceProvider>(context, listen: false).updateFilter('Completed');
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RaceProvider>(context);
    final filteredRaces = provider.races; // Now returns List<RaceDTO>

    return Scaffold(
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.refresh,
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
                            onChanged: provider.updateSearch,
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
                                  provider.updateSearch('');
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
                  final raceDate = race.startTime != null
                      ? "${_formatMonthDay(race.startTime)}, ${race.startTime.year}"
                      : 'Unknown';
                  
                  // We need to determine the number of participants
                  // This might require updating the RaceDTO to include a participants count
                  // For now, we'll use the segments count as a proxy
                  final totalParticipants = race.segments.length;

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