import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../../core/constants/user_role.dart';
import '../cubit/admin_cubit.dart';

class AdminUserCard extends StatelessWidget {
  final User user;
  final bool isOperating;

  const AdminUserCard({
    super.key,
    required this.user,
    required this.isOperating,
  });

  Future<void> _changeRole(BuildContext context) async {
    final newRole = user.role == UserRole.user.name.toUpperCase()
      ? 'ADMIN'
      : 'USER';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Role'),
          content: Text(
            'Change ${user.email} to $newRole?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Change'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await context.read<AdminCubit>().changeUserRole(
          userId: user.id,
          role: newRole,
        );
  }

  Future<void> _deleteUser(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text(
            'Are you sure you want to delete ${user.email}?\n\n'
            'This will also delete all of this user\'s check-ins.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await context.read<AdminCubit>().deleteUser(
          userId: user.id,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == UserRole.admin.name.toUpperCase();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    user.email.isNotEmpty
                        ? user.email[0].toUpperCase()
                        : '?',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('ID: ${user.id}'),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    isAdmin ? 'ADMIN' : 'USER',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: isOperating
                      ? null
                      : () => _changeRole(context),
                  icon: const Icon(Icons.manage_accounts),
                  label: Text(
                    isAdmin ? 'Make User' : 'Make Admin',
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Delete User',
                  onPressed: isOperating
                      ? null
                      : () => _deleteUser(context),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}