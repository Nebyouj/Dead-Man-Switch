import 'package:dartz/dartz.dart';
import 'package:mobile_app/features/admin/domain/entities/admin_stats.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/admin_checkin.dart';

abstract class AdminRepository {
  Future<Either<Failure, AdminStats>> getStats();

  Future<Either<Failure, List<User>>> getUsers();

  Future<Either<Failure, List<AdminCheckIn>>> getCheckIns();

  Future<Either<Failure, AdminCheckIn>> cancelCheckIn({
    required int checkInId,
  });

  Future<Either<Failure, void>> deleteUser({
    required int userId,
  });

  Future<Either<Failure, User>> updateUserRole({
    required int userId,
    required String role,
  });
}