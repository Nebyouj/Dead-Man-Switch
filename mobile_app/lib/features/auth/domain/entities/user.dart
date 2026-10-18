import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String role;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, role, createdAt];
}
