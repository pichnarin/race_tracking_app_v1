import 'package:flutter/material.dart';

class ResultDetailProvider with ChangeNotifier {
  List<Map<String, dynamic>> _participants = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get participants => _participants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadParticipants(Map<String, dynamic>? raceData) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final participantsMap =
          (raceData?['participants'] as Map?)?.cast<String, dynamic>() ?? {};

      _participants =
          participantsMap.values
              .map((e) => e as Map<String, dynamic>)
              .where(
                (p) => p['totalTime'] != null && p['totalTime'] != '00:00:00',
              )
              .toList();

      _participants.sort((a, b) {
        final timeA = _parseDuration(a['totalTime']);
        final timeB = _parseDuration(b['totalTime']);
        return timeA.compareTo(timeB);
      });
    } catch (e) {
      _error = 'Failed to load participants: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Duration _parseDuration(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return Duration.zero;
    final parts = timeStr.split(':').map(int.parse).toList();
    if (parts.length == 3) {
      return Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
    }
    return Duration.zero;
  }
}
