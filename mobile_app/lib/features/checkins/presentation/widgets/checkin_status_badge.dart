import 'package:flutter/material.dart';

import '../../domain/entities/checkin_status.dart';

class CheckInStatusBadge extends StatelessWidget {
  final CheckInStatus status;

  const CheckInStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (status) {
      CheckInStatus.active => (
          'ACTIVE',
          Icons.access_time,
        ),
      CheckInStatus.triggered => (
          'TRIGGERED',
          Icons.notifications_active,
        ),
      CheckInStatus.cancelled => (
          'CANCELLED',
          Icons.cancel_outlined,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _backgroundColor(CheckInStatus status) {
    switch (status) {
      case CheckInStatus.active:
        return Colors.green.withValues(alpha: 0.15);
      case CheckInStatus.triggered:
        return Colors.orange.withValues(alpha: 0.15);
      case CheckInStatus.cancelled:
        return Colors.grey.withValues(alpha: 0.15);
    }
  }
}