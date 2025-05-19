import 'package:flutter/material.dart';
import 'package:race_tracking_app_v1/data/repo/firebase_race_repo.dart';
import 'package:race_tracking_app_v1/data/DTO/participants_dto.dart';
import '/model/participants.dart';

class ParticipantProvider extends ChangeNotifier {
  final FireRaceRepo _raceRepo = FireRaceRepo();
  
  List<ParticipantDTO> _participants = [];
  bool _isLoading = false;
  String _currentRaceId = '';

  // Getters
  List<ParticipantDTO> get participants => _participants;
  bool get isLoading => _isLoading;
  String get currentRaceId => _currentRaceId;
  FireRaceRepo get raceRepo => _raceRepo;

  // Load participants for a specific race
  Future<void> loadParticipants(String raceId) async {
    _isLoading = true;
    _currentRaceId = raceId;
    notifyListeners();
    
    try {
      final participantsMap = await _raceRepo.fetchRaceParticipantById(raceId);
      // Convert Map objects to ParticipantDTO objects
      _participants = participantsMap.map((p) => ParticipantDTO.fromJson(p)).toList();
    } catch (e) {
      print('Error loading participants: $e');
      _participants = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addParticipant({
    required String name,
    required String bib,
    required String raceId,
  }) async {
    try {
      await _raceRepo.addParticipant(
        name: name,
        bib: bib,
        raceId: raceId,
        segmentStartTimes: {},
        segmentFinishTimes: {},
        totalTime: '00:00:00',
      );
      
      // Reload participants to reflect the changes
      await loadParticipants(raceId);
    } catch (e) {
      print('Error adding participant: $e');
      throw e; // Re-throw to allow the UI to handle the error
    }
  }

  // Check if all participants have finished
  bool allParticipantsFinished() {
    return _participants.isNotEmpty &&
        _participants.every((p) {
          final time = p.totalTime.trim();
          return time.isNotEmpty && time != '00:00:00';
        });
  }

  // Record segment time for a participant
  Future<void> recordSegmentTime({
    required String bib,
    required String segment,
    required DateTime finishTime,
  }) async {
    await _raceRepo.recordSegmentTime(
      raceId: _currentRaceId,
      bib: bib,
      segment: segment,
      finishTime: finishTime,
    );
    
    await loadParticipants(_currentRaceId);
  }
}