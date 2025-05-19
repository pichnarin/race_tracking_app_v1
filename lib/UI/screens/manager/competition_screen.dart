// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app_v1/UI/provider/race_provider.dart';
import 'package:race_tracking_app_v1/UI/theme/app_color.dart';
import 'package:race_tracking_app_v1/data/DTO/races_dto.dart';
import '../../widget/Form/create_race.dart';
import '../../widget/manager/race_card.dart';
import 'detail_screen.dart';


class CompetitionScreen extends StatefulWidget {
  const CompetitionScreen({super.key});

  @override
  State<CompetitionScreen> createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RaceProvider>(context, listen: false).loadRaces();
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
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: provider.refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //header
                      Container(
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Center(
                                child: Text(
                                  "Competitions",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => CreateRaceForm(
                                        onRaceCreated: (createdRace) {
                                          provider.loadRaces(); // Use provider to refresh
                                        },
                                      ),
                                );
                              },
                              icon: const Icon(Icons.add, color: Colors.white),
                              tooltip: 'Add a new race',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          "Featured Races",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Filter and Search Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: searchController,
                                onChanged: provider.updateSearch,
                                decoration: InputDecoration(
                                  hintText: "Search races...",
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon:
                                      searchController.text.isNotEmpty
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
                            ),

                            const SizedBox(width: 5),

                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                value: provider.selectedFilter,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value != null) {
                                    provider.updateFilter(value);
                                  }
                                },
                                items:
                                    ['All', 'Upcoming', 'Started', 'Completed']
                                        .map(
                                          (status) => DropdownMenuItem<String>(
                                            value: status,
                                            child: Text(status),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      if (filteredRaces.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredRaces.length,
                          itemBuilder: (context, index) {
                            final race = filteredRaces[index];
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
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          child: Text("No races found for this filter."),
                        ),
                    ],
                  ),
                ),
              ),
    );
  }
}

// Utilities
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

extension StringCasingExtension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}