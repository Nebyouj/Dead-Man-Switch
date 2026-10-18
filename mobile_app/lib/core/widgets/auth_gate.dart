import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/constants/user_role.dart';
import 'package:mobile_app/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:mobile_app/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:mobile_app/features/checkins/presentation/cubit/checkin_cubit.dart';
import 'package:mobile_app/injection_container.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/checkins/presentation/pages/home_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();

    context.read<AuthCubit>().checkAuthenticationStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthAuthenticated) {
          if (state.user.role == UserRole.admin.name.toUpperCase()) {
            return BlocProvider(
              create: (_) => sl<AdminCubit>(),
              child: const AdminDashboardPage(),
            );
          }
          return BlocProvider(
            create: (_) => sl<CheckInCubit>(),
            child: const HomePage(),
          );
        }

        return const AuthPage();
      },
    );
  }
}
