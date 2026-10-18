import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/entities/checkin_status.dart';

class CheckInCountdown extends StatefulWidget {
  final DateTime deadline;
  final CheckInStatus status;

  const CheckInCountdown({
    super.key,
    required this.deadline,
    required this.status,
  });

  @override
  State<CheckInCountdown> createState() => _CheckInCountdownState();
}

class _CheckInCountdownState extends State<CheckInCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();

    _updateRemaining();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRemaining(),
    );
  }

  @override
  void didUpdateWidget(covariant CheckInCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.deadline != widget.deadline ||
        oldWidget.status != widget.status) {
      _updateRemaining();
    }
  }

  void _updateRemaining() {
    final difference = widget.deadline.difference(
      DateTime.now(),
    );

    if (!mounted) return;

    setState(() {
      _remaining = difference.isNegative
          ? Duration.zero
          : difference;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status != CheckInStatus.active) {
      return _buildInactiveState();
    }

    if (_remaining == Duration.zero) {
      return _buildExpiredState();
    }

    return _buildCountdown();
  }

  Widget _buildCountdown() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.withValues(alpha: 0.08),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.timer_outlined,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Time remaining',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDuration(_remaining),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.orange.withValues(alpha: 0.12),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 22,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Deadline reached',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInactiveState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.withValues(alpha: 0.08),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.timer_off_outlined,
            size: 22,
          ),
          const SizedBox(width: 10),
          Text(
            _statusText(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _statusText() {
    switch (widget.status) {
      case CheckInStatus.active:
        return 'Active';
      case CheckInStatus.triggered:
        return 'Check-in triggered';
      case CheckInStatus.cancelled:
        return 'Check-in cancelled';
    }
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    }

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }

    return '${seconds}s';
  }
}