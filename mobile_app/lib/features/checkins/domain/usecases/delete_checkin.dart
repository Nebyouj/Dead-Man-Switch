import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/checkin_repository.dart';

class DeleteCheckIn {
  final CheckInRepository repository;

  const DeleteCheckIn(this.repository);

  Future<Either<Failure, void>> call({required int checkInId}) {
    return repository.deleteCheckIn(checkInId: checkInId);
  }
}
