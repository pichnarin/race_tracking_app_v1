import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/result_detail_screen.dart';

class ResultDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? raceData;

  const ResultDetailScreen({super.key, this.raceData});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResultDetailProvider()..loadParticipants(raceData),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Race Results"),
          backgroundColor: Colors.blue,
        ),
        body: Consumer<ResultDetailProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(
                child: Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }

            final participants = provider.participants;

            if (participants.isEmpty) {
              return const Center(child: Text("No results to display."));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: participants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final p = participants[index];
                final rank = index + 1;
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        child: Text(rank.toString()),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text("Bib: ${p['bib'] ?? '-'}"),
                          ],
                        ),
                      ),
                      Text(
                        p['totalTime'] ?? '--:--:--',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
