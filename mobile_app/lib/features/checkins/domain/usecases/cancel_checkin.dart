import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/checkin.dart';
import '../repositories/checkin_repository.dart';

class CancelCheckIn {
  final CheckInRepository repository;

  const CancelCheckIn(this.repository);

  Future<Either<Failure, CheckIn>> call({required int checkInId}) {
    return repository.cancelCheckIn(checkInId: checkInId);
  }
}
