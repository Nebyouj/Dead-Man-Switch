import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/checkins/domain/entities/checkin.dart';
import 'package:mobile_app/features/checkins/domain/repositories/checkin_repository.dart';

class TriggerCheckIn {
  final CheckInRepository repository;

  TriggerCheckIn(this.repository);

  Future<Either<Failure, CheckIn>> call({required int checkInId}) {
    return repository.triggerCheckIn(checkInId: checkInId);
  }
}
