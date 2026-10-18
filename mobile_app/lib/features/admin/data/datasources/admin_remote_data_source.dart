import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/admin_checkin_model.dart';
import '../models/admin_stats_model.dart';

abstract class AdminRemoteDataSource {
  Future<AdminStatsModel> getStats();

  Future<List<UserModel>> getUsers();

  Future<List<AdminCheckInModel>> getCheckIns();

  Future<AdminCheckInModel> cancelCheckIn({
    required int checkInId,
  });

  Future<void> deleteUser({
    required int userId,
  });

  Future<UserModel> updateUserRole({
    required int userId,
    required String role,
  });
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiClient apiClient;

  const AdminRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AdminStatsModel> getStats() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.adminStats,
    );

    return AdminStatsModel.fromJson(response.data!);
  }

  @override
  Future<List<UserModel>> getUsers() async {
    final response = await apiClient.get<List<dynamic>>(
      ApiConstants.adminUsers,
    );

    return response.data!
        .map(
          (json) => UserModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<List<AdminCheckInModel>> getCheckIns() async {
    final response = await apiClient.get<List<dynamic>>(
      ApiConstants.adminCheckins,
    );

    return response.data!
        .map(
          (json) => AdminCheckInModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<AdminCheckInModel> cancelCheckIn({
    required int checkInId,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.adminCheckins}/$checkInId/cancel',
    );

    return AdminCheckInModel.fromJson(response.data!);
  }

  @override
  Future<void> deleteUser({
    required int userId,
  }) async {
    await apiClient.delete<void>(
      '${ApiConstants.adminUsers}/$userId',
    );
  }

  @override
  Future<UserModel> updateUserRole({
    required int userId,
    required String role,
  }) async {
    final response = await apiClient.put<Map<String, dynamic>>(
      '${ApiConstants.adminUsers}/$userId/role',
      data: {
        'role': role,
      },
    );

    return UserModel.fromJson(response.data!);
  }
}