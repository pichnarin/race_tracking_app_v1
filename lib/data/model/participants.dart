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

  // DTO: Converts JSON from Firestore to Participant object
  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      name: json['name'],
      pid: json['pid'] ?? '',
      bib: json['bib'] ?? '',
      raceId: json['raceId'] ?? '',
      segmentStartTimes: (json['segmentStartTimes'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, DateTime.parse(value)))
          ?? {},
      segmentFinishTimes: (json['segmentFinishTimes'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, DateTime.parse(value)))
          ?? {},
      totalTime: json['totalTime'] ?? '00:00:00',
    );
  }

  // Converts Participant object to JSON map for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'bib': bib,
      'name': name,
      'race_id': raceId, // Mapping raceId to database field
      'segmentStartTimes': segmentStartTimes.map((key, value) =>
          MapEntry(key, value.toIso8601String())),
      'segmentFinishTimes': segmentFinishTimes.map((key, value) =>
          MapEntry(key, value.toIso8601String())),
      'totalTime': totalTime,
    };
  }
}
