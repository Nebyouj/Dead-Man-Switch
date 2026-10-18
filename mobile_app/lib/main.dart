import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/widgets/auth_gate.dart';
import 'package:mobile_app/features/auth/presentation/cubit/auth_cubit.dart';

import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDependencies();

  runApp(const DeadManSwitchApp());
}

class DeadManSwitchApp extends StatelessWidget {
  const DeadManSwitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dead Man Switch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        inputDecorationTheme: const InputDecorationTheme(filled: true),
      ),
      home: BlocProvider(
        create: (_) => sl<AuthCubit>(),
        child: const AuthGate(),
      ),
    );
  }
}
