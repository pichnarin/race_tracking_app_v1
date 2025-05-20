import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app_v1/UI/providers/race_provider.dart';
import 'package:race_tracking_app_v1/UI/theme/app_color.dart';
import 'package:race_tracking_app_v1/model/participants.dart';
import 'package:race_tracking_app_v1/model/races.dart';

import '../../../providers/tracking_provider.dart';
import '../../manager/result_detail_screen.dart';

class TrackingPage extends StatefulWidget {
  final Race race;

  const TrackingPage({super.key, required this.race});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  void showLog(String message) {
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    final raceId = widget.race.uid;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
      final raceProvider = Provider.of<RaceProvider>(context, listen: false);

      trackingProvider.setCurrentRace(raceId);
      await raceProvider.fetchParticipants(raceId);
      trackingProvider.initializeSegmentCounts(raceProvider.participants);
    });
  }

  @override
  Widget build(BuildContext context) {
    final trackingProvider = Provider.of<TrackingProvider>(context);
    final raceProvider = Provider.of<RaceProvider>(context);

    final selectedBib = trackingProvider.selectedBib;
    final currentSegment = trackingProvider.getNextSegment();
    final allFinished = raceProvider.participants.isNotEmpty &&
        trackingProvider.allParticipantsFinished(raceProvider.participants);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        title: Text(widget.race.name,style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      floatingActionButton: allFinished
          ? FloatingActionButton.extended(
              onPressed: () {
                final updatedRaceData = {
                  ...widget.race.toJson(),
                  'participants': {
                    for (var p in raceProvider.participants) p.bib: p.toJson(),
                  },
                };
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultDetailScreen(raceData: updatedRaceData),
                  ),
                );
              },
              icon: const Icon(Icons.emoji_events, color: Colors.white),
              label: const Text("See Results",style: TextStyle(color: Colors.white),),
              backgroundColor: AppColor.primary,
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildRaceInfo(widget.race),
            const SizedBox(height: 24),
            const Text(
              "Participants",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (raceProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (raceProvider.participants.isEmpty)
              const Text("No participants found.")
            else
              _buildBibSelector(
                raceProvider.participants,
                trackingProvider.selectedBib,
                trackingProvider,
              ),
            const SizedBox(height: 24),
            if (selectedBib != null) ...[
              Text(
                "Selected Bib: $selectedBib",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                "Current Segment: ${currentSegment.isNotEmpty ? StringCasing(currentSegment).capitalize() : "All done!"}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (currentSegment.isNotEmpty)
                _buildRecordButton(
                  currentSegment,
                  selectedBib,
                  widget.race.uid,
                  raceProvider,
                  trackingProvider,
                )
              else
                const Text(
                  "🎉 All Segments Recorded",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
            ] else
              const Text(
                "⬅️ Tap a bib to begin tracking.",
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRaceInfo(Race race) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📍 Location: ${race.location}"),
            const SizedBox(height: 4),
            Text("⏰ Start Time: ${race.startTime}"),
            const SizedBox(height: 4),
            Text("📌 Status: ${StringCasing(race.status.name).capitalize()}"),
          ],
        ),
      ),
    );
  }

  Widget _buildBibSelector(
    List<Participant> participants,
    String? selectedBib,
    TrackingProvider trackingProvider,
  ) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: participants.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final bib = participants[index].bib;
          final isSelected = selectedBib == bib;

          return GestureDetector(
            onTap: () => trackingProvider.selectBib(bib),
            child: Container(
              width: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColor.primary : AppColor.secondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.blueAccent : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Text(
                bib,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordButton(
    String segment,
    String bib,
    String raceId,
    RaceProvider raceProvider,
    TrackingProvider trackingProvider,
  ) {
    return ElevatedButton.icon(
      onPressed: () async {
        final now = DateTime.now();
        try {
          await raceProvider.recordSegmentTime(
            raceId: raceId,
            bib: bib,
            segment: segment,
            finishTime: now,
          );
          // showLog("✅ Recorded $segment for bib $bib");
          trackingProvider.incrementSegmentCount();
        } catch (e) {
          showLog("❌ Failed to record $segment: $e");
        }
      },
      icon: const Icon(Icons.save_alt),
      label: Text("Record ${StringCasing(segment).capitalize()}"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

extension StringCasing on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
