import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/checkins/domain/entities/checkin_status.dart';

import '../../domain/entities/admin_checkin.dart';
import '../cubit/admin_cubit.dart';

class AdminCheckInCard extends StatelessWidget {
  final AdminCheckIn adminCheckIn;
  final bool isOperating;

  const AdminCheckInCard({
    super.key,
    required this.adminCheckIn,
    required this.isOperating,
  });

  Future<void> _cancelCheckIn(BuildContext context) async {
    final checkIn = adminCheckIn.checkIn;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Force Cancel'),
          content: Text(
            'Cancel "${checkIn.name}"?\n\n'
            'This action will cancel the check-in for the user.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await context.read<AdminCubit>().cancelCheckIn(
          checkInId: checkIn.id,
        );
  }

  @override
  Widget build(BuildContext context) {
    final checkIn = adminCheckIn.checkIn;
    final user = adminCheckIn.user;

    final isActive = checkIn.status == CheckInStatus.active;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    checkIn.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusChip(status: checkIn.status),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(user.email),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Deadline: ${_formatDateTime(checkIn.deadline)}',
                ),
              ],
            ),

            if (checkIn.message != null &&
                checkIn.message!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                checkIn.message!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (isActive) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: isOperating
                      ? null
                      : () => _cancelCheckIn(context),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Force Cancel'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();

    String twoDigits(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${local.year}-${twoDigits(local.month)}-'
        '${twoDigits(local.day)} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }
}

class _StatusChip extends StatelessWidget {
  final CheckInStatus status;

  const _StatusChip({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    String label;

    switch (status) {
      case CheckInStatus.active:
        label = 'ACTIVE';
        break;
      case CheckInStatus.triggered:
        label = 'TRIGGERED';
        break;
      case CheckInStatus.cancelled:
        label = 'CANCELLED';
        break;
    }

    return Chip(
      label: Text(label),
    );
  }
}