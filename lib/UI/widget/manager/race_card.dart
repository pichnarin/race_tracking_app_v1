import 'package:flutter/material.dart';

class RaceCard extends StatelessWidget {
  final String raceName;
  final String raceDate;
  final String totalParticipants;
  final String raceStatus;
  final VoidCallback? onTap;

  const RaceCard({
    super.key,
    this.onTap,
    required this.raceName,
    required this.raceDate,
    required this.totalParticipants,
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
        return Colors.grey.shade200;
    }
  }

  Color _getTextColor(String status) {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 350;

    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade400,
                radius: 20,
                child: Text(
                  raceName.isNotEmpty ? raceName[0].toUpperCase() : '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      raceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 13 : 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$totalParticipants ${totalParticipants == "1" ? "participant" : "participants"} · $raceDate",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(raceStatus),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  raceStatus,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(raceStatus),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
