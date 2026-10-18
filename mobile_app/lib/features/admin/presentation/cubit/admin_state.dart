import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_checkin.dart';
import '../../domain/entities/admin_stats.dart';
import '../../../auth/domain/entities/user.dart';

class AdminState extends Equatable {
  final AdminStats? stats;
  final List<User> users;
  final List<AdminCheckIn> checkIns;
  final bool isLoading;
  final bool isOperating;
  final String? errorMessage;

  const AdminState({
    this.stats,
    this.users = const [],
    this.checkIns = const [],
    this.isLoading = false,
    this.isOperating = false,
    this.errorMessage,
  });

  AdminState copyWith({
    AdminStats? stats,
    List<User>? users,
    List<AdminCheckIn>? checkIns,
    bool? isLoading,
    bool? isOperating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminState(
      stats: stats ?? this.stats,
      users: users ?? this.users,
      checkIns: checkIns ?? this.checkIns,
      isLoading: isLoading ?? this.isLoading,
      isOperating: isOperating ?? this.isOperating,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        stats,
        users,
        checkIns,
        isLoading,
        isOperating,
        errorMessage,
      ];
}