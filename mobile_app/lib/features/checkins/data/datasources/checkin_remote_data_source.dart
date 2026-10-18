import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/checkin_create_model.dart';
import '../models/checkin_model.dart';

abstract class CheckInRemoteDataSource {
  Future<List<CheckInModel>> getCheckIns();

  Future<CheckInModel> getCheckIn({required int checkInId});

  Future<CheckInModel> createCheckIn({required CheckInCreateModel checkIn});

  Future<void> deleteCheckIn({required int checkInId});

  Future<CheckInModel> resetCheckIn({required int checkInId});

  Future<CheckInModel> cancelCheckIn({required int checkInId});

  Future<CheckInModel> triggerCheckIn({required int checkInId});
}

class CheckInRemoteDataSourceImpl implements CheckInRemoteDataSource {
  final ApiClient apiClient;

  const CheckInRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<CheckInModel>> getCheckIns() async {
    final response = await apiClient.get<List<dynamic>>(ApiConstants.checkins);

    return response.data!
        .map((json) => CheckInModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CheckInModel> getCheckIn({required int checkInId}) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.checkins}/$checkInId',
    );

    return CheckInModel.fromJson(response.data!);
  }

  @override
  Future<CheckInModel> createCheckIn({
    required CheckInCreateModel checkIn,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.checkins,
      data: checkIn.toJson(),
    );

    return CheckInModel.fromJson(response.data!);
  }

  @override
  Future<void> deleteCheckIn({required int checkInId}) async {
    await apiClient.delete<void>('${ApiConstants.checkins}/$checkInId');
  }

  @override
  Future<CheckInModel> resetCheckIn({required int checkInId}) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.checkins}/$checkInId/check-in',
    );

    return CheckInModel.fromJson(response.data!);
  }

  @override
  Future<CheckInModel> cancelCheckIn({required int checkInId}) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.checkins}/$checkInId/cancel',
    );

    return CheckInModel.fromJson(response.data!);
  }

  @override
  Future<CheckInModel> triggerCheckIn({required int checkInId}) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.checkins}/$checkInId/trigger',
    );

    return CheckInModel.fromJson(response.data!);
  }
}
