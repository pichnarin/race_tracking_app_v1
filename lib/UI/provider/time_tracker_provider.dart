// providers/time_tracker_provider.dart
import 'package:flutter/material.dart';
import 'package:race_tracking_app_v1/data/repo/firebase_race_repo.dart';
import 'package:race_tracking_app_v1/data/DTO/races_dto.dart';
import 'package:race_tracking_app_v1/data/DTO/participants_dto.dart';

class TimeTrackerProvider extends ChangeNotifier {
  final FireRaceRepo _raceRepo = FireRaceRepo();
  
  List<RaceDTO> _activeRaces = [];
  List<RaceDTO> _completedRaces = [];
  bool _isLoading = false;
  String _searchText = '';
  
  // Getters
  List<RaceDTO> get activeRaces => _activeRaces;
  List<RaceDTO> get completedRaces => _completedRaces;
  List<RaceDTO> get filteredCompletedRaces => _completedRaces
      .where((race) => race.name.toLowerCase().contains(_searchText.toLowerCase()))
      .toList();
  bool get isLoading => _isLoading;
  FireRaceRepo get raceRepo => _raceRepo;
  
  // Initialize
  TimeTrackerProvider() {
    loadRaces();
  }
  
  // Load races
  Future<void> loadRaces() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final racesData = await _raceRepo.fetchRaceDetails();
      final races = racesData.map((race) => RaceDTO.fromJson(race)).toList();
      
      _activeRaces = races
          .where((race) => race.status.name.toLowerCase() == 'started')
          .toList();
          
      _completedRaces = races
          .where((race) => race.status.name.toLowerCase() == 'completed')
          .toList();
          
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading races: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update search text for filtering
  void updateSearch(String value) {
    _searchText = value;
    notifyListeners();
  }
  
  // Record segment time
  Future<void> recordSegmentTime({
    required String raceId,
    required String bib,
    required String segment,
    required DateTime finishTime,
  }) async {
    try {
      await _raceRepo.recordSegmentTime(
        raceId: raceId,
        bib: bib,
        segment: segment,
        finishTime: finishTime,
      );
      
      // Reload races to get updated data
      await loadRaces();
    } catch (e) {
      print('Error recording segment time: $e');
      throw e; // Re-throw to allow UI to handle the error
    }
  }
  
  // Check if all participants in a race have finished
  Future<bool> allParticipantsFinished(RaceDTO race) async {
    try {
      // We need to fetch the participants for this race
      final participantsData = await _raceRepo.fetchRaceParticipantById(race.uid);
      final participants = participantsData.map((p) => ParticipantDTO.fromJson(p)).toList();
      
      // Check if all participants have a total time
      return participants.isNotEmpty &&
          participants.every((p) {
            final time = p.totalTime.trim();
            return time.isNotEmpty && time != '00:00:00';
          });
    } catch (e) {
      print('Error checking if all participants finished: $e');
      return false;
    }
  }
}