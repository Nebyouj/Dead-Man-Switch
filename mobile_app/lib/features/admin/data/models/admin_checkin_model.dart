import '../../../auth/data/models/user_model.dart';
import '../../../checkins/data/models/checkin_model.dart';
import '../../domain/entities/admin_checkin.dart';

class AdminCheckInModel extends AdminCheckIn {
  const AdminCheckInModel({
    required super.checkIn,
    required super.user,
  });

  factory AdminCheckInModel.fromJson(Map<String, dynamic> json) {
    return AdminCheckInModel(
      checkIn: CheckInModel.fromJson(json),
      user: UserModel.fromJson(
        json['user'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final checkInJson = checkIn is CheckInModel
        ? (checkIn as CheckInModel).toJson()
        : <String, dynamic>{};

    return {
      ...checkInJson,
      'user': user is UserModel
          ? (user as UserModel).toJson()
          : null,
    };
  }
}