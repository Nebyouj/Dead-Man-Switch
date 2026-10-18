import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_respository.dart';

class CheckAuthStatus {
  final AuthRepository repository;

  const CheckAuthStatus(this.repository);

  Future<Either<Failure, User>> call() async {
    final hasToken = await repository.hasToken();

    if (!hasToken) {
      return const Left(UnauthorizedFailure('No active session.'));
    }

    return repository.getCurrentUser();
  }
}
