import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app_v1/UI/theme/app_color.dart';
import '../../widget/manager/race_card.dart';
import 'result_detail_screen.dart';
import '../../providers/result_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResultProvider()..loadRaceList(),
      child: Scaffold(
        body: Consumer<ResultProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Text(
                  provider.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: provider.filteredRaces.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Header
                  return Container(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: TextField(
                      onChanged: provider.updateSearchText,
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
                            provider.filteredRaces.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: provider.clearSearch,
                                )
                                : null,
                      ),
                    ),
                  );
                }

                // Race cards
                final race = provider.filteredRaces[index - 2];
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
                    vertical: 6,
                  ),
                  child: RaceCard(
                    raceName: raceName,
                    raceDate: raceDate,
                    totalParticipants: "$totalParticipants participants",
                    raceStatus: status.toString().capitalize(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ResultDetailScreen(raceData: race),
                        ),
                      );
                    },
                  ),
                );
              },
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
