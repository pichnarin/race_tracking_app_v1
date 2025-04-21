import '../model/participants.dart';

abstract class RaceRepo{
  void startRaceEvent();
  Future<void> addParticipant(Participant participant);
  Future<void> updateParticipant(Participant participant);
  Future<void> deleteParticipant(String bib);
  Future<List<Participant>> fetchParticipants(String raceId);
  Future<void> fetchDashboardScore(String raceId);
}