import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/checkins/domain/entities/notification_channel.dart';
import 'package:mobile_app/features/checkins/presentation/cubit/checkin_operation.dart';

import '../../domain/entities/checkin.dart';
import '../../domain/entities/checkin_status.dart';
import '../cubit/checkin_cubit.dart';
import '../cubit/checkin_state.dart';
import '../widgets/checkin_countdown.dart';
import '../widgets/checkin_status_badge.dart';

class CheckInDetailPage extends StatefulWidget {
  final int checkInId;

  const CheckInDetailPage({super.key, required this.checkInId});

  @override
  State<CheckInDetailPage> createState() => _CheckInDetailPageState();
}

class _CheckInDetailPageState extends State<CheckInDetailPage> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckInCubit>().loadCheckIn(checkInId: widget.checkInId);
    });

    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;

      final state = context.read<CheckInCubit>().state;

      if (state is CheckInLoaded && !state.isOperating) {
        context.read<CheckInCubit>().loadCheckIn(checkInId: widget.checkInId);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<CheckInCubit>().loadCheckIn(checkInId: widget.checkInId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In Details'),
        actions: [
          BlocBuilder<CheckInCubit, CheckInState>(
            builder: (context, state) {
              final isOperating = state is CheckInLoaded && state.isOperating;

              return IconButton(
                onPressed: isOperating ? null : _refresh,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<CheckInCubit, CheckInState>(
        listener: (context, state) {
          if (state is CheckInError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is CheckInUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Check-in updated successfully')),
            );
          }

          if (state is CheckInDeleted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Check-in deleted')));

            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          if (state is CheckInLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CheckInLoaded) {
            return _buildContent(
              context,
              state.checkIn,
              isOperating: state.isOperating,
              operation: state.operation,
            );
          }

          if (state is CheckInError) {
            return _buildError(context, state.message);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CheckIn checkIn, {
    required bool isOperating,
    required CheckInOperation? operation,
  }) {
    final isActive = checkIn.status == CheckInStatus.active;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(checkIn),
          const SizedBox(height: 16),

          CheckInCountdown(deadline: checkIn.deadline, status: checkIn.status),

          const SizedBox(height: 20),

          _buildInformationCard(checkIn),

          const SizedBox(height: 16),

          _buildNotificationCard(checkIn),

          const SizedBox(height: 16),

          if (isActive)
            _buildActiveActions(
              context,
              checkIn,
              isOperating: isOperating,
              operation: operation,
            )
          else
            _buildInactiveActions(
              context,
              checkIn,
              isOperating: isOperating,
              operation: operation,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(CheckIn checkIn) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    checkIn.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                CheckInStatusBadge(status: checkIn.status),
              ],
            ),
            if (checkIn.message != null &&
                checkIn.message!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                checkIn.message!,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInformationCard(CheckIn checkIn) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Check-In Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _InfoRow(
              icon: Icons.timer_outlined,
              label: 'Duration',
              value: _formatDuration(checkIn.durationMinutes),
            ),

            const Divider(height: 24),

            _InfoRow(
              icon: Icons.event_outlined,
              label: 'Deadline',
              value: _formatDateTime(checkIn.deadline),
            ),

            const Divider(height: 24),

            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Created',
              value: _formatDateTime(checkIn.createdAt),
            ),

            if (checkIn.triggeredAt != null) ...[
              const Divider(height: 24),
              _InfoRow(
                icon: Icons.notifications_active_outlined,
                label: 'Triggered',
                value: _formatDateTime(checkIn.triggeredAt!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(CheckIn checkIn) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (checkIn.channels.isEmpty)
              const Text('No notification channels configured.'),

            ...checkIn.channels.map(
              (channel) => _buildChannelRow(checkIn, channel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelRow(CheckIn checkIn, NotificationChannel channel) {
    switch (channel.toString()) {
      case 'NotificationChannel.email':
        return _NotificationRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: checkIn.recipientEmail ?? 'Not configured',
        );

      case 'NotificationChannel.sms':
        return _NotificationRow(
          icon: Icons.sms_outlined,
          label: 'SMS',
          value: checkIn.recipientPhone ?? 'Not configured',
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildActiveActions(
    BuildContext context,
    CheckIn checkIn, {
    required bool isOperating,
    required CheckInOperation? operation,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: isOperating
                  ? null
                  : () => _confirmCheckIn(context, checkIn),
              icon: operation == CheckInOperation.checkIn
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: const Text('Check In'),
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: isOperating
                  ? null
                  : () => _confirmCancel(context, checkIn),
              icon: operation == CheckInOperation.cancel
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cancel_outlined),
              label: const Text('Cancel Check-In'),
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: isOperating
                  ? null
                  : () => _confirmTrigger(context, checkIn),
              icon: operation == CheckInOperation.trigger
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.notifications_active_outlined),
              label: const Text('Trigger Now'),
            ),

            const SizedBox(height: 10),

            TextButton.icon(
              onPressed: isOperating
                  ? null
                  : () => _confirmDelete(context, checkIn),
              icon: operation == CheckInOperation.delete
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInactiveActions(
    BuildContext context,
    CheckIn checkIn, {
    required bool isOperating,
    required CheckInOperation? operation,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: isOperating
                  ? null
                  : () => _confirmDelete(context, checkIn),
              icon: operation == CheckInOperation.delete
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCheckIn(BuildContext context, CheckIn checkIn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Check In?'),
          content: const Text(
            'This will reset the deadline and keep the check-in active.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Check In'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await context.read<CheckInCubit>().reset(checkInId: checkIn.id);

      if (context.mounted) {
        await _refresh();
      }
    }
  }

  Future<void> _confirmCancel(BuildContext context, CheckIn checkIn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Check-In?'),
          content: const Text(
            'The check-in will no longer trigger notifications.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep Active'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Cancel Check-In'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await context.read<CheckInCubit>().cancel(checkInId: checkIn.id);

      if (context.mounted) {
        await _refresh();
      }
    }
  }

  Future<void> _confirmTrigger(BuildContext context, CheckIn checkIn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Trigger Check-In?'),
          content: const Text(
            'This will immediately trigger the configured notifications.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Trigger'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await context.read<CheckInCubit>().trigger(checkInId: checkIn.id);

      if (context.mounted) {
        await _refresh();
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, CheckIn checkIn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Check-In?'),
          content: Text('Are you sure you want to delete "${checkIn.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await context.read<CheckInCubit>().delete(checkInId: checkIn.id);
    }
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return hours == 1 ? '1 hour' : '$hours hours';
    }

    return '${hours}h ${remainingMinutes}m';
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;

    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year at $hour:$minute';
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
        Icon(icon, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _NotificationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
