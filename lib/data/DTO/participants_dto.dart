import '../../model/participants.dart';

class ParticipantDTO {
  final String pid;
  final String bib;
  final String name;
  final String raceId;
  final Map<String, DateTime> segmentStartTimes;
  final Map<String, DateTime> segmentFinishTimes;
  final String totalTime;

  ParticipantDTO({
    required this.pid,
    required this.bib,
    required this.name,
    required this.raceId,
    required this.segmentStartTimes,
    required this.segmentFinishTimes,
    required this.totalTime,
  });

  factory ParticipantDTO.fromJson(Map<String, dynamic> json) {
    return ParticipantDTO(
      name: json['name'],
      pid: json['pid'] ?? '',
      bib: json['bib'] ?? '',
      raceId: json['raceId'] ?? '',
      segmentStartTimes: (json['segmentStartTimes'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, DateTime.parse(value))) ??
          {},
      segmentFinishTimes: (json['segmentFinishTimes'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, DateTime.parse(value))) ??
          {},
      totalTime: json['totalTime'] ?? '00:00:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pid': pid,
      'name': name,
      'bib': bib,
      'raceId': raceId,
      'segmentStartTimes': segmentStartTimes.map((key, value) =>
          MapEntry(key, value.toIso8601String())),
      'segmentFinishTimes': segmentFinishTimes.map((key, value) =>
          MapEntry(key, value.toIso8601String())),
      'totalTime': totalTime,
    };
  }

  // Conversion: DTO -> Model
  Participant toModel() {
    return Participant(
      pid: pid,
      bib: bib,
      name: name,
      raceId: raceId,
      segmentStartTimes: segmentStartTimes,
      segmentFinishTimes: segmentFinishTimes,
      totalTime: totalTime,
    );
  }

  // Conversion: Model -> DTO
  factory ParticipantDTO.fromModel(Participant model) {
    return ParticipantDTO(
      pid: model.pid,
      bib: model.bib,
      name: model.name,
      raceId: model.raceId,
      segmentStartTimes: model.segmentStartTimes,
      segmentFinishTimes: model.segmentFinishTimes,
      totalTime: model.totalTime,
    );
  }
}
