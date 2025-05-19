import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app_v1/UI/theme/app_color.dart';
import '../../providers/race_provider.dart';
import '../../widget/Form/create_race.dart';
import '../../widget/manager/race_card.dart';
import 'detail_screen.dart';

class CompetitionScreen extends StatefulWidget {
  const CompetitionScreen({super.key});

  @override
  State<CompetitionScreen> createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen> {
  String selectedFilter = "All";
  String searchText = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<RaceProvider>(context, listen: false).fetchRaces();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> getFilteredRaces(RaceProvider provider) {
    return provider.races
        .where((race) {
          final raceName = (race.name ?? '').toLowerCase();
          final raceStatus = race.status.name.toLowerCase();
          final matchesSearch = raceName.contains(searchText.toLowerCase());
          final matchesFilter =
              selectedFilter == 'All' ||
              raceStatus == selectedFilter.toLowerCase();
          return matchesSearch && matchesFilter;
        })
        .map((race) => race.toJson())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RaceProvider>(
      builder: (context, provider, child) {
        final filteredRaces = getFilteredRaces(provider);

        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                                  repo:
                                      Provider.of<RaceProvider>(
                                        context,
                                        listen: false,
                                      ).repo,
                                  onRaceCreated: (_) {
                                    Provider.of<RaceProvider>(
                                      context,
                                      listen: false,
                                    ).fetchRaces();
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
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Featured Races",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                // Search & Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            setState(() => searchText = value);
                          },
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
                                        setState(() => searchText = '');
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
                          value: selectedFilter,
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
                              setState(() => selectedFilter = value);
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

                if (provider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (filteredRaces.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredRaces.length,
                    itemBuilder: (context, index) {
                      final race = filteredRaces[index];
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
                              StringCasingExtension(
                                status.toString(),
                              ).capitalize(),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        RaceDetailScreen(raceData: race),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Text("No races found for this filter."),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Utilities

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
