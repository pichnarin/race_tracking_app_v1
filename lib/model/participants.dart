class Participant {
  late final String pid;
  final String bib;
  final String name;
  final String raceId;
  final Map<String, DateTime> segmentStartTimes;
  final Map<String, DateTime> segmentFinishTimes;
  final String totalTime;

  Participant({
    required this.pid,
    required this.bib,
    required this.name,
    required this.raceId,
    required this.segmentStartTimes,
    required this.segmentFinishTimes,
    required this.totalTime,
  });

  @override
  bool operator ==(Object other) {
    return other is Participant && other.pid == pid;
  }

  @override
  int get hashCode => super.hashCode ^ pid.hashCode;

}
