import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/checkin.dart';
import '../repositories/checkin_repository.dart';

class ResetCheckIn {
  final CheckInRepository repository;

  const ResetCheckIn(this.repository);

  Future<Either<Failure, CheckIn>> call({required int checkInId}) {
    return repository.resetCheckIn(checkInId: checkInId);
  }
}
