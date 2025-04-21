class Participant {
  final String bib;
  final String raceId;
  final Map<String, DateTime> segmentStartTimes;
  final Map<String, DateTime> segmentFinishTimes;
  final String totalTime;

  Participant({
    required this.bib,
    required this.raceId,
    required this.segmentStartTimes,
    required this.segmentFinishTimes,
    required this.totalTime,
  });
}
