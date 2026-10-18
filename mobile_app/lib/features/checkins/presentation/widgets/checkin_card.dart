import 'package:flutter/material.dart';
import 'package:mobile_app/features/checkins/presentation/widgets/checkin_countdown.dart';

import '../../domain/entities/checkin.dart';
import '../../domain/entities/checkin_status.dart';
import '../../domain/entities/notification_channel.dart';
import 'checkin_status_badge.dart';

class CheckInCard extends StatelessWidget {
  final CheckIn checkIn;
  final VoidCallback onCheckIn;
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final VoidCallback onTrigger;
  final bool isOperating;

  const CheckInCard({
    super.key,
    required this.checkIn,
    required this.onCheckIn,
    required this.onCancel,
    required this.onDelete,
    required this.onTrigger,
    this.isOperating = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = checkIn.status == CheckInStatus.active;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                CheckInStatusBadge(status: checkIn.status),
              ],
            ),

            const SizedBox(height: 12),

            if (checkIn.message != null && checkIn.message!.isNotEmpty) ...[
              Text(
                checkIn.message!,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
            ],

            _InfoRow(
              icon: Icons.timer_outlined,
              label: 'Duration',
              value: '${checkIn.durationMinutes} minutes',
            ),

            const SizedBox(height: 8),

            _InfoRow(
              icon: Icons.event_outlined,
              label: 'Deadline',
              value: _formatDateTime(checkIn.deadline),
            ),

            const SizedBox(height: 12),

            CheckInCountdown(
              deadline: checkIn.deadline,
              status: checkIn.status,
            ),

            const SizedBox(height: 12),

            _InfoRow(
              icon: Icons.notifications_outlined,
              label: 'Channels',
              value: _formatChannels(checkIn.channels),
            ),

            if (checkIn.recipientEmail != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: checkIn.recipientEmail!,
              ),
            ],

            if (checkIn.recipientPhone != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: checkIn.recipientPhone!,
              ),
            ],

            const SizedBox(height: 16),

            if (isActive)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isOperating ? null : onCheckIn,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Check In'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    enabled: !isOperating,
                    onSelected: (value) {
                      switch (value) {
                        case 'cancel':
                          onCancel();
                          break;
                        case 'trigger':
                          onTrigger();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'cancel',
                        child: ListTile(
                          leading: Icon(Icons.cancel_outlined),
                          title: Text('Cancel'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'trigger',
                        child: ListTile(
                          leading: Icon(Icons.notifications_active_outlined),
                          title: Text('Trigger'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline),
                          title: Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: isOperating ? null : onDelete,
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatChannels(List<NotificationChannel> channels) {
    return channels
        .map((channel) {
          switch (channel) {
            case NotificationChannel.email:
              return 'Email';
            case NotificationChannel.sms:
              return 'SMS';
          }
        })
        .join(', ');
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();

    final hour = local.hour > 12
        ? local.hour - 12
        : local.hour == 0
        ? 12
        : local.hour;

    final minute = local.minute.toString().padLeft(2, '0');

    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '${local.day}/${local.month}/${local.year} '
        '$hour:$minute $period';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value)),
      ],
    );
  }
}
