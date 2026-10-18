import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/admin_checkin_card.dart';

class AdminCheckInsPage extends StatelessWidget {
  const AdminCheckInsPage({super.key});

  Future<void> _refresh(BuildContext context) async {
    await context.read<AdminCubit>().loadCheckIns();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Check-Ins'),
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.checkIns.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.checkIns.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Text('No check-ins found.'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.checkIns.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final adminCheckIn = state.checkIns[index];

                return AdminCheckInCard(
                  adminCheckIn: adminCheckIn,
                  isOperating: state.isOperating,
                );
              },
            ),
          );
        },
      ),
    );
  }
}