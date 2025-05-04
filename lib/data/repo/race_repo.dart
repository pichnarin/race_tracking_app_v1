import 'package:race_tracking_app_v1/data/model/races.dart';

import '../model/participants.dart';

abstract class RaceRepo {
  Future<Race> createRace({
    required String name,
    required RaceStatus status,
    required DateTime startTime,
    required Map<String, RaceSegmentDetail> segments,
  });

  Future<void> startRaceEvent(String raceId);

  Future<Participant> addParticipant({
    required String bib,
    required String raceId,
    required String name,
    required Map<String, DateTime> segmentStartTimes,
    required Map<String, DateTime> segmentFinishTimes,
    required String totalTime,
  });

  Future<void> updateParticipant(Participant participant);

  Future<void> deleteParticipant(String bib);

  Future<List<Participant>> fetchParticipants(String raceId);

  Future<Participant?> fetchParticipant(String bib);

  Future<void> recordSegmentTime({
    required String raceId,
    required String bib,
    required String segment,
    required DateTime finishTime,
  });
  Future<List<Participant>> fetchDashboardScore(String raceId);

  Future<Map<String, Race>> fetchRaces();

  Future<Race?> fetchRace(String raceId);

  Future<List<Map<String, dynamic>>> fetchRaceDetails();
}
