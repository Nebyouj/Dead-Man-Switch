import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/checkin.dart';
import '../repositories/checkin_repository.dart';

class GetCheckIns {
  final CheckInRepository repository;

  const GetCheckIns(this.repository);

  Future<Either<Failure, List<CheckIn>>> call() {
    return repository.getCheckIns();
  }
}
