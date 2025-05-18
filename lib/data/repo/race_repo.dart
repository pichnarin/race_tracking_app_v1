import 'package:race_tracking_app_v1/model/races.dart';
import '../../model/participants.dart';
import '../../model/race_segments_detail.dart';

abstract class RaceRepo {
  Future<Race> createRace({
    required String name,
    required RaceStatus status,
    required DateTime startTime,
    required Map<String, RaceSegmentDetail> segments,
    required String location,
  });

  Future<void> startRaceEvent(String raceId);

  Future<void> endRaceEvent(String raceId);

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

  Future<Map<String, Race>> fetchRace(String raceId);

  Future<List<Map<String, dynamic>>> fetchRaceDetails();

  Future<List<Map<String, dynamic>>> fetchRaceParticipantById(String raceId);

}
