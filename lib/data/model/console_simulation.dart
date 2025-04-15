import 'package:race_tracking_app_v1/data/model/participant_time_record.dart';

import 'Triathlon.dart';

void main() async {
  // Simulate Participants
  final participants = {
    101: ParticipantTimeRecord(bib: 101),
    102: ParticipantTimeRecord(bib: 102),
  };

  print("🏁 Race Manager starts the race...");
  final raceStart = DateTime.now();
  print("Race started at: $raceStart\n");

  // Delay for simulation
  Future<void> simulateDelay(String action, [int seconds = 2]) async {
    print(action);
    await Future.delayed(Duration(seconds: seconds));
  }

  // 🏊 Swim Segment
  await simulateDelay("🏊‍♀️ Participants are swimming...");
  participants[101]!.setSegmentTime(Triathlon.swimming, DateTime.now());
  await simulateDelay("BIB 101 finished swimming");
  participants[102]!.setSegmentTime(Triathlon.swimming, DateTime.now());
  await simulateDelay("BIB 102 finished swimming");

  // 🚴 Cycle Segment
  await simulateDelay("🚴 Participants are cycling...");
  participants[101]!.setSegmentTime(Triathlon.cycling, DateTime.now());
  await simulateDelay("BIB 101 finished cycling");
  participants[102]!.setSegmentTime(Triathlon.cycling, DateTime.now());
  await simulateDelay("BIB 102 finished cycling");

  // 🏃 Run Segment
  await simulateDelay("🏃 Participants are running...");
  participants[101]!.setSegmentTime(Triathlon.running, DateTime.now());
  await simulateDelay("BIB 101 finished running");
  participants[102]!.setSegmentTime(Triathlon.running, DateTime.now());
  await simulateDelay("BIB 102 finished running");

  // 🏁 Race Finished
  print("\n🏁 Race Finished! Final Results:\n");
  print("Rank\tBIB\tSwim\t\tCycle\t\tRun\t\tTotal");

  // Sort by total time
  final sorted = participants.values.toList()
    ..sort((a, b) => a.totalTime!.compareTo(b.totalTime!));

  for (int i = 0; i < sorted.length; i++) {
    print('${i + 1}\t${sorted[i].resultRow(raceStart)}');
  }
}