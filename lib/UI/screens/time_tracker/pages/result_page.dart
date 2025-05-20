import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app_v1/UI/theme/app_color.dart';
import 'package:race_tracking_app_v1/UI/widget/manager/race_card.dart';
// import '../../../models/race.dart';
import '../../../providers/race_provider.dart';
import '../../manager/result_detail_screen.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RaceProvider>(context, listen: false).fetchRaceDetails();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final raceProvider = Provider.of<RaceProvider>(context);
    final races = raceProvider.races;

    // Filter races based on search and completed status
    final filteredRaces =
        races.where((race) {
          final name = race.name.toLowerCase();
          final status = race.status.name.toLowerCase();
          final matchesSearch =
              searchText.isEmpty || name.contains(searchText.toLowerCase());
          final isCompleted = status == 'completed';
          return matchesSearch && isCompleted;
        }).toList();

    return Scaffold(
      body: Column(
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
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search races...",
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon:
                              searchController.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      searchController.clear();
                                      setState(() {
                                        searchText = '';
                                      });
                                    },
                                  )
                                  : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Race List
          Expanded(
            child:
                raceProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredRaces.isEmpty
                    ? const Center(child: Text("No completed races found"))
                    : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: filteredRaces.length,
                      itemBuilder: (context, index) {
                        final race = filteredRaces[index];
                        final raceDate =
                            "${_formatMonthDay(race.startTime)}, ${race.startTime.year}";
                        final totalParticipants =
                            race.participants?.length ?? 0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: RaceCard(
                            raceName: race.name,
                            raceDate: raceDate,
                            totalParticipants:
                                "$totalParticipants participants",
                            raceStatus: StringCasingExtension(race.status.name).capitalize(),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ResultDetailScreen(
                                        raceData: race.toJson(),
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
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
}

extension StringCasingExtension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
