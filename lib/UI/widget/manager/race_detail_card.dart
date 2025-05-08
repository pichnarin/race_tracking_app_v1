import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RaceDetailCard extends StatelessWidget {
  final String raceName;
  // final String raceDate;
  final DateTime startTime;
  final String location;
  final String raceStatus;

  const RaceDetailCard({
    super.key,
    required this.raceName,
    // required this.raceDate,
    required this.startTime,
    required this.location,
    required this.raceStatus,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade100;
      case 'upcoming':
        return Colors.blue.shade100;
      case 'started':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade800;
      case 'upcoming':
        return Colors.blue.shade800;
      case 'started':
        return Colors.orange.shade800;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {

    final formattedDate = DateFormat.yMMMMd().format(startTime);
    final formattedTime = DateFormat.jm().format(startTime);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              raceName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.calendar_today, "Date", formattedDate),
            _buildDetailRow(Icons.access_time, "Start Time", formattedTime),
            _buildDetailRow(Icons.location_on, "Location", location),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(raceStatus),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                raceStatus,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _getStatusTextColor(raceStatus),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
