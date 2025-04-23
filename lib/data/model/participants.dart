class Participant {
  late final String pid;
  final String bib;
  final String raceId;
  final Map<String, DateTime> segmentStartTimes;
  final Map<String, DateTime> segmentFinishTimes;
  final String totalTime;

  Participant({
    required this.pid,
    required this.bib,
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



  // DTO: Converts JSON from Firestore to Participant object
  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      pid: json['pid'].toString(),
      bib: json['bib'].toString(),
      raceId: json['race_id'] as String,
      segmentStartTimes: Map<String, DateTime>.from(
        json['segmentStartTimes'].map((key, value) => MapEntry(
            key, DateTime.parse(value))),
      ),
      segmentFinishTimes: Map<String, DateTime>.from(
        json['segmentFinishTimes'].map((key, value) => MapEntry(
            key, DateTime.parse(value))),
      ),
      totalTime: json['totalTime'] as String,
    );
  }

  // Converts Participant object to JSON map for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'bib': bib,
      'race_id': raceId, // Mapping raceId to database field
      'segmentStartTimes': segmentStartTimes.map((key, value) =>
          MapEntry(key, value.toIso8601String())),
      'segmentFinishTimes': segmentFinishTimes.map((key, value) =>
          MapEntry(key, value.toIso8601String())),
      'totalTime': totalTime,
    };
  }
}
