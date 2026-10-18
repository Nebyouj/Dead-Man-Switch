import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Intitial state before authentication status is checked.
class AuthInitial extends AuthState {}

/// Checking whether the user already has a valid session.
class AuthLoading extends AuthState {}

/// User is authenticated and has a valid session.
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthRegistrationSuccess extends AuthState {
  final String email;

  const AuthRegistrationSuccess(this.email);

  @override
  List<Object?> get props => [email];
}


/// Authentication failed or the user is not authenticated.
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthUnAuthenticated extends AuthState {}