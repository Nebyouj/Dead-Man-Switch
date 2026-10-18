import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/admin_repostiory.dart';

class GetUsers {
  final AdminRepository repository;

  const GetUsers(this.repository);

  Future<Either<Failure, List<User>>> call() {
    return repository.getUsers();
  }
}
