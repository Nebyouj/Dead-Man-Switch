import 'package:dartz/dartz.dart';
import 'package:mobile_app/features/admin/domain/entities/admin_checkin.dart';

import '../../../../core/error/failures.dart';
import '../repositories/admin_repostiory.dart';

class ForceCancelCheckin {
  final AdminRepository repository;

  const ForceCancelCheckin(this.repository);

  Future<Either<Failure, AdminCheckIn>> call({required int checkInId}) {
    return repository.cancelCheckIn(checkInId: checkInId);
  }
}
