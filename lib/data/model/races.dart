enum RaceStatus { started, ended }

enum Segments { swimming, cycling, running }

class Race {
  final String uid;
  final RaceStatus status;
  final DateTime raceStartTime;
  final Segments segment;

  Race({
    required this.uid,
    required this.status,
    required this.raceStartTime,
    required this.segment,
  });
}
