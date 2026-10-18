import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/admin/domain/entities/admin_checkin.dart';
import 'package:mobile_app/features/admin/domain/entities/admin_stats.dart';
import 'package:mobile_app/features/admin/domain/usecases/delete_user.dart';
import 'package:mobile_app/features/admin/domain/usecases/force_cancel_checkin.dart';
import 'package:mobile_app/features/admin/domain/usecases/get_all_checkin.dart';
import 'package:mobile_app/features/admin/domain/usecases/get_users.dart';
import 'package:mobile_app/features/auth/domain/entities/user.dart';

import '../../domain/usecases/get_admin_stats.dart';
import '../../domain/usecases/update_user_role.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final GetAdminStats getAdminStats;
  final GetUsers getUsers;
  final GetAllCheckin getAllCheckin;
  final ForceCancelCheckin forceCancelCheckin;
  final DeleteUser deleteUser;
  final UpdateUserRole updateUserRole;

  AdminCubit({
    required this.getAdminStats,
    required this.getUsers,
    required this.getAllCheckin,
    required this.forceCancelCheckin,
    required this.deleteUser,
    required this.updateUserRole,
  }) : super(const AdminState());

  Future<void> loadDashboard() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final statsResult = await getAdminStats();
    final usersResult = await getUsers();
    final checkInsResult = await getAllCheckin();

    AdminStats? stats;
    List<User> users = [];
    List<AdminCheckIn> checkIns = [];
    String? errorMessage;

    statsResult.fold(
      (failure) {
        errorMessage ??= failure.message;
      },
      (value) {
        stats = value;
      },
    );

    usersResult.fold(
      (failure) {
        errorMessage ??= failure.message;
      },
      (value) {
        users = value;
      },
    );

    checkInsResult.fold(
      (failure) {
        errorMessage ??= failure.message;
      },
      (value) {
        checkIns = value;
      },
    );

    emit(
      state.copyWith(
        stats: stats,
        users: users,
        checkIns: checkIns,
        isLoading: false,
        errorMessage: errorMessage,
      ),
    );
  }

  Future<void> loadStats() async {
    final result = await getAdminStats();

    result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
      },
      (stats) {
        emit(state.copyWith(stats: stats, clearError: true));
      },
    );
  }

  Future<void> loadUsers() async {
    final result = await getUsers();

    result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
      },
      (users) {
        emit(state.copyWith(users: users, clearError: true));
      },
    );
  }

  Future<void> loadCheckIns() async {
    final result = await getAllCheckin();

    result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
      },
      (checkIns) {
        emit(state.copyWith(checkIns: checkIns, clearError: true));
      },
    );
  }

  Future<bool> cancelCheckIn({required int checkInId}) async {
    emit(state.copyWith(isOperating: true, clearError: true));

    final result = await forceCancelCheckin(checkInId: checkInId);

    return result.fold(
      (failure) {
        emit(state.copyWith(isOperating: false, errorMessage: failure.message));

        return false;
      },
      (cancelledCheckIn) {
        final updatedCheckIns = state.checkIns.map((adminCheckIn) {
          if (adminCheckIn.checkIn.id == cancelledCheckIn.checkIn.id) {
            return cancelledCheckIn;
          }

          return adminCheckIn;
        }).toList();

        emit(
          state.copyWith(
            checkIns: updatedCheckIns,
            isOperating: false,
            clearError: true,
          ),
        );

        return true;
      },
    );
  }

  Future<bool> deleteUsers({required int userId}) async {
    emit(state.copyWith(isOperating: true, clearError: true));

    final result = await deleteUser(userId: userId);

    return result.fold(
      (failure) {
        emit(state.copyWith(isOperating: false, errorMessage: failure.message));

        return false;
      },
      (_) {
        final updatedUsers = state.users
            .where((user) => user.id != userId)
            .toList();

        final updatedCheckIns = state.checkIns
            .where((item) => item.user.id != userId)
            .toList();

        emit(
          state.copyWith(
            users: updatedUsers,
            checkIns: updatedCheckIns,
            isOperating: false,
            clearError: true,
          ),
        );

        return true;
      },
    );
  }

  Future<bool> changeUserRole({
    required int userId,
    required String role,
  }) async {
    emit(state.copyWith(isOperating: true, clearError: true));

    final result = await updateUserRole(userId: userId, role: role);

    return result.fold(
      (failure) {
        emit(state.copyWith(isOperating: false, errorMessage: failure.message));

        return false;
      },
      (updatedUser) {
        final updatedUsers = state.users.map((user) {
          if (user.id == updatedUser.id) {
            return updatedUser;
          }

          return user;
        }).toList();

        final updatedCheckIns = state.checkIns.map((item) {
          if (item.user.id == updatedUser.id) {
            return AdminCheckIn(checkIn: item.checkIn, user: updatedUser);
          }

          return item;
        }).toList();

        emit(
          state.copyWith(
            users: updatedUsers,
            checkIns: updatedCheckIns,
            isOperating: false,
            clearError: true,
          ),
        );

        return true;
      },
    );
  }
}
