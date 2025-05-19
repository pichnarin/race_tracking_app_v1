import 'package:flutter/material.dart';
import 'package:race_tracking_app_v1/data/repo/firebase_race_repo.dart';
import 'package:race_tracking_app_v1/data/DTO/races_dto.dart';
import 'package:race_tracking_app_v1/model/race_segments_detail.dart';
import '/model/races.dart';

class RaceProvider extends ChangeNotifier {
  final FireRaceRepo _raceRepo = FireRaceRepo();
  
  List<RaceDTO> _races = [];
  List<RaceDTO> _filteredRaces = [];
  bool _isLoading = false;
  String _searchText = '';
  String _selectedFilter = 'All';

  // Getters
  List<RaceDTO> get races => _filteredRaces;
  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;
  FireRaceRepo get raceRepo => _raceRepo;
  
  // Initialize
  RaceProvider() {
    loadRaces();
  }

  // Load all races
  Future<void> loadRaces() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final raceDetails = await _raceRepo.fetchRaceDetails();
      // Convert Map objects to RaceDTO objects
      _races = raceDetails.map((race) => RaceDTO.fromJson(race)).toList();
      _applyFilters();
    } catch (e) {
      print('Error loading races: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh races
  Future<void> refresh() async {
    await loadRaces();
  }

  // Update search text
  void updateSearch(String value) {
    _searchText = value;
    _applyFilters();
  }

  // Update filter
  void updateFilter(String value) {
    _selectedFilter = value;
    _applyFilters();
  }

  // Apply filters
  void _applyFilters() {
    _filteredRaces = _races.where((race) {
      final name = race.name.toLowerCase();
      final status = race.status.name.toLowerCase();

      final matchesSearch = name.contains(_searchText.toLowerCase());
      
      bool matchesFilter;
      if (_selectedFilter == 'All') {
        matchesFilter = true;
      } else if (_selectedFilter == 'Upcoming') {
        matchesFilter = status == 'upcoming';
      } else if (_selectedFilter == 'Started') {
        matchesFilter = status == 'started';
      } else if (_selectedFilter == 'Completed') {
        matchesFilter = status == 'completed';
      } else {
        matchesFilter = true;
      }

      return matchesSearch && matchesFilter;
    }).toList();
    
    notifyListeners();
  }

  // Get a specific race by ID
  RaceDTO? getRaceById(String raceId) {
    try {
      return _races.firstWhere(
        (race) => race.uid == raceId,
      );
    } catch (e) {
      return null;
    }
  }

  // Create a new race
  Future<Race> createRace({
    required String name,
    required RaceStatus status,
    required DateTime startTime,
    required Map<String, RaceSegmentDetail> segments,
    required String location,
  }) async {
    final race = await _raceRepo.createRace(
      name: name,
      status: status,
      startTime: startTime,
      segments: segments,
      location: location,
    );
    
    await loadRaces();
    return race;
  }

  // Start a race
  Future<void> startRace(String raceId) async {
    await _raceRepo.startRaceEvent(raceId);
    await loadRaces();
  }

  // End a race
  Future<void> endRace(String raceId) async {
    await _raceRepo.endRaceEvent(raceId);
    await loadRaces();
  }
}