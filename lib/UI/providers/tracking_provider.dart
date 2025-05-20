import 'package:flutter/material.dart';
import 'package:race_tracking_app_v1/model/participants.dart';

class TrackingProvider with ChangeNotifier {
  // Selected participant tracking
  String? _selectedBib;
  final Map<String, int> _segmentCounts = {};
  
  // Current race tracking
  String? _currentRaceId;
  
  // Getters
  String? get selectedBib => _selectedBib;
  String? get currentRaceId => _currentRaceId;
  int get currentSegmentCount => _selectedBib != null ? (_segmentCounts[_selectedBib] ?? 0) : 0;
  
  // Set the current race being tracked
  void setCurrentRace(String raceId) {
    _currentRaceId = raceId;
    notifyListeners();
  }
  
  // Select a participant by bib number
  void selectBib(String bib) {
    _selectedBib = bib;
    notifyListeners();
  }
  
  // Clear selected participant
  void clearSelection() {
    _selectedBib = null;
    notifyListeners();
  }
  
  // Get the next segment based on count
  String getNextSegment() {
    final count = currentSegmentCount;
    if (count == 0) return 'swimming';
    if (count == 1) return 'cycling';
    if (count == 2) return 'running';
    return '';
  }
  
  // Increment segment count for selected bib
  void incrementSegmentCount() {
    if (_selectedBib != null) {
      _segmentCounts[_selectedBib!] = currentSegmentCount + 1;
      notifyListeners();
    }
  }
  
  // Check if participant has completed all segments
  bool hasCompletedAllSegments(String bib) {
    return (_segmentCounts[bib] ?? 0) >= 3;
  }
  
  // Check if all participants in a list have completed all segments
  bool allParticipantsFinished(List<Participant> participants) {
    if (participants.isEmpty) return false;
    
    return participants.every((participant) {
      // Check if all segments have finish times
      final hasSwimming = participant.segmentFinishTimes['swimming'] != null;
      final hasCycling = participant.segmentFinishTimes['cycling'] != null;
      final hasRunning = participant.segmentFinishTimes['running'] != null;
      
      return hasSwimming && hasCycling && hasRunning;
    });
  }
  
  // Initialize segment counts based on existing data
  void initializeSegmentCounts(List<Participant> participants) {
    _segmentCounts.clear();
    
    for (final participant in participants) {
      int count = 0;
      if (participant.segmentFinishTimes['swimming'] != null) count++;
      if (participant.segmentFinishTimes['cycling'] != null) count++;
      if (participant.segmentFinishTimes['running'] != null) count++;
      
      _segmentCounts[participant.bib] = count;
    }
    
    notifyListeners();
  }
  
  // Reset tracking state
  void reset() {
    _segmentCounts.clear();
    _selectedBib = null;
    _currentRaceId = null;
    notifyListeners();
  }
}