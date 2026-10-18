import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/admin_checkin.dart';
import '../repositories/admin_repostiory.dart';

class GetAllCheckin {
  final AdminRepository repository;

  const GetAllCheckin(this.repository);

  Future<Either<Failure, List<AdminCheckIn>>> call() {
    return repository.getCheckIns();
  }
}
