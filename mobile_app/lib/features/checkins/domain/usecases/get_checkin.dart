import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/checkin.dart';
import '../repositories/checkin_repository.dart';

class GetCheckIn {
  final CheckInRepository repository;

  const GetCheckIn(this.repository);

  Future<Either<Failure, CheckIn>> call({required int checkInId}) {
    return repository.getCheckIn(checkInId: checkInId);
  }
}
