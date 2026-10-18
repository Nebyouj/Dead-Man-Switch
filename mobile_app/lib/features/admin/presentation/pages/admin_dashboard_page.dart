import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import 'admin_checkins_page.dart';
import 'admin_users_page.dart';
import '../widgets/admin_stat_card.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();

    context.read<AdminCubit>().loadDashboard();
  }

  Future<void> _refresh() async {
    await context.read<AdminCubit>().loadDashboard();
  }

  void _openUsers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AdminCubit>(),
          child: const AdminUsersPage(),
        ),
      ),
    );
  }

  void _openCheckIns() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AdminCubit>(),
          child: const AdminCheckInsPage(),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await context.read<AuthCubit>().logoutUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state.isLoading && state.stats == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.errorMessage != null && state.stats == null) {
            return _ErrorView(
              message: state.errorMessage!,
              onRetry: _refresh,
            );
          }

          final stats = state.stats;

          if (stats == null) {
            return const Center(
              child: Text('No dashboard data available.'),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'System Overview',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    AdminStatCard(
                      title: 'Total Users',
                      value: stats.totalUsers.toString(),
                      icon: Icons.people,
                    ),
                    AdminStatCard(
                      title: 'Active Check-Ins',
                      value: stats.totalActiveCheckIns.toString(),
                      icon: Icons.timer,
                    ),
                    AdminStatCard(
                      title: 'Triggered Check-Ins',
                      value: stats.totalTriggeredCheckIns.toString(),
                      icon: Icons.warning_amber_rounded,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                const Text(
                  'Management',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                _ManagementCard(
                  icon: Icons.people_outline,
                  title: 'Users',
                  subtitle: '${state.users.length} users',
                  onTap: _openUsers,
                ),

                const SizedBox(height: 12),

                _ManagementCard(
                  icon: Icons.timer_outlined,
                  title: 'Check-Ins',
                  subtitle: '${state.checkIns.length} check-ins',
                  onTap: _openCheckIns,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ManagementCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}