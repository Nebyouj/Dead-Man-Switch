import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/checkin.dart';
import '../cubit/checkin_cubit.dart';
import '../cubit/checkin_state.dart';
import '../widgets/checkin_card.dart';
import 'check_in_detail_page.dart';
import 'create_checkin_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckInCubit>().loadCheckIns();
    });

    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;

      context.read<CheckInCubit>().loadCheckIns();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _openCreateCheckIn() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CheckInCubit>(),
          child: const CreateCheckInPage())
      ),
    );

    if (!mounted) return;

    context.read<CheckInCubit>().loadCheckIns();
  }

  Future<void> _confirmDelete(CheckIn checkIn) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete check-in?'),
          content: Text(
            'Are you sure you want to delete '
            '"${checkIn.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    context.read<CheckInCubit>().delete(checkInId: checkIn.id);
  }

  Future<void> _confirmCancel(CheckIn checkIn) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel check-in?'),
          content: Text('The check-in "${checkIn.name}" will be cancelled.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Keep'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Cancel Check-In'),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true || !mounted) return;

    context.read<CheckInCubit>().cancel(checkInId: checkIn.id);
  }

  Future<void> _confirmTrigger(CheckIn checkIn) async {
    final shouldTrigger = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Trigger check-in?'),
          content: Text(
            'This will immediately trigger the notification '
            'for "${checkIn.name}".',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Trigger'),
            ),
          ],
        );
      },
    );

    if (shouldTrigger != true || !mounted) return;

    context.read<CheckInCubit>().trigger(checkInId: checkIn.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dead Man Switch'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthCubit>().logoutUser();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateCheckIn,
        icon: const Icon(Icons.add),
        label: const Text('Create Check-In'),
      ),
      body: BlocConsumer<CheckInCubit, CheckInState>(
        listener: (context, state) {
          if (state is CheckInError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is CheckInsLoaded &&
              state.operationMessage != null &&
              !state.isOperating) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.operationMessage!)));
          }
        },
        builder: (context, state) {
          if (state is CheckInLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CheckInError) {
            return _ErrorView(
              message: state.message,
              onRetry: () {
                context.read<CheckInCubit>().loadCheckIns();
              },
            );
          }

          if (state is CheckInsLoaded) {
            return _CheckInList(
              checkIns: state.checkIns,
              isOperating: state.isOperating,
              onRefresh: () {
                return context.read<CheckInCubit>().loadCheckIns();
              },
              onCheckIn: (checkIn) {
                context.read<CheckInCubit>().reset(checkInId: checkIn.id);
              },
              onCancel: _confirmCancel,
              onDelete: _confirmDelete,
              onTrigger: _confirmTrigger,
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _CheckInList extends StatelessWidget {
  final List<CheckIn> checkIns;
  final bool isOperating;
  final Future<void> Function() onRefresh;
  final void Function(CheckIn checkIn) onCheckIn;
  final void Function(CheckIn checkIn) onCancel;
  final void Function(CheckIn checkIn) onDelete;
  final void Function(CheckIn checkIn) onTrigger;

  const _CheckInList({
    required this.checkIns,
    required this.isOperating,
    required this.onRefresh,
    required this.onCheckIn,
    required this.onCancel,
    required this.onDelete,
    required this.onTrigger,
  });

  @override
  Widget build(BuildContext context) {
    if (checkIns.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 120),
            Icon(Icons.timer_outlined, size: 72),
            SizedBox(height: 20),
            Center(
              child: Text(
                'No check-ins yet',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'Create a check-in to get started.',
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 120),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Text(
            '${checkIns.length} Check-In${checkIns.length == 1 ? '' : 's'}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(
            'Manage your scheduled check-ins.',
            style: TextStyle(color: Colors.grey.shade700),
          ),

          const SizedBox(height: 20),

          if (isOperating)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(),
            ),

          ...checkIns.map(
            (checkIn) => GestureDetector(
              onTap: () async {
                final deleted = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<CheckInCubit>(),
                      child: CheckInDetailPage(
                        checkInId: checkIn.id,
                      ),
                    ),
                  ),
                );

                if (deleted == true && context.mounted) {
                  context.read<CheckInCubit>().loadCheckIns();
                }
              },
              child: CheckInCard(
                checkIn: checkIn,
                isOperating: isOperating,
                onCheckIn: () => onCheckIn(checkIn),
                onCancel: () => onCancel(checkIn),
                onDelete: () => onDelete(checkIn),
                onTrigger: () => onTrigger(checkIn),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
