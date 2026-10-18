import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../checkins/domain/entities/checkin.dart';

class AdminCheckIn extends Equatable {
  final CheckIn checkIn;
  final User user;

  const AdminCheckIn({
    required this.checkIn,
    required this.user,
  });

  @override
  List<Object?> get props => [
        checkIn,
        user,
      ];
}