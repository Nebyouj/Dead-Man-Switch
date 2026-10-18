import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/admin_repostiory.dart';

class DeleteUser {
  final AdminRepository repository;

  const DeleteUser(this.repository);

  Future<Either<Failure, void>> call({required int userId}) {
    return repository.deleteUser(userId: userId);
  }
}
