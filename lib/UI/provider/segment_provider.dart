// providers/segment_provider.dart
import 'package:flutter/material.dart';

class SegmentProvider extends ChangeNotifier {
  String _currentSegment = 'swimming'; // Default segment
  List<String> _participants = [];
  
  // Getters
  String get currentSegment => _currentSegment;
  List<String> get participants => _participants;
  
  // Set current segment
  void setSegment(String segment) {
    _currentSegment = segment;
    notifyListeners();
  }
  
  // Add participant
  void addParticipant(String bib) {
    if (!_participants.contains(bib)) {
      _participants.add(bib);
      notifyListeners();
    }
  }
  
  // Remove participant
  void removeParticipant(String bib) {
    _participants.remove(bib);
    notifyListeners();
  }
  
  // Clear all participants
  void clearParticipants() {
    _participants.clear();
    notifyListeners();
  }
}