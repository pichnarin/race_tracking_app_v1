import 'Triathlon.dart';

class ParticipantTimeRecord {
  final int bib;
  DateTime? swimmingTime;
  DateTime? cyclingTime;
  DateTime? runningTime;

  ParticipantTimeRecord({required this.bib});

  void setSegmentTime(Triathlon segment, DateTime time) {
    switch (segment) {
      case Triathlon.swimming:
        swimmingTime = time;
        break;
      case Triathlon.cycling:
        cyclingTime = time;
        break;
      case Triathlon.running:
        runningTime = time;
        break;
    }
  }

  Duration? get totalTime {
    if (swimmingTime != null && cyclingTime != null && runningTime != null) {
      return runningTime!.difference(swimmingTime!);
    }
    return null; // not finished yet
  }

  String getTimeString(DateTime? t, DateTime start) {
    if (t == null) return '--:--';
    final diff = t.difference(start);
    return diff.toString().split('.').first;
  }

  String resultRow(DateTime raceStart) {
    return 'BIB $bib\t'
        'Swim: ${getTimeString(swimmingTime, raceStart)}\t'
        'Cycle: ${getTimeString(cyclingTime, raceStart)}\t'
        'Run: ${getTimeString(runningTime, raceStart)}\t'
        'Total: ${totalTime != null ? totalTime.toString().split('.').first : "--:--"}';
  }
}
