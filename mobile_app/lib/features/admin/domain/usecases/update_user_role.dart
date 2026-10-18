import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/admin_repostiory.dart';

class UpdateUserRole {
  final AdminRepository repository;

  const UpdateUserRole(this.repository);

  Future<Either<Failure, User>> call({
    required int userId,
    required String role,
  }) {
    return repository.updateUserRole(userId: userId, role: role);
  }
}
