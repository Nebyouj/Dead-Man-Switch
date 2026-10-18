import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/admin_stats.dart';
import '../repositories/admin_repostiory.dart';

class GetAdminStats {
  final AdminRepository repository;

  const GetAdminStats(this.repository);

  Future<Either<Failure, AdminStats>> call() {
    return repository.getStats();
  }
}
