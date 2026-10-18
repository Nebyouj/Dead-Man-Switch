import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_respository.dart';

class GetCurrentUser {
  final AuthRepository respository;

  GetCurrentUser(this.respository);

  Future<Either<Failure, User>> call() {
    return respository.getCurrentUser();
  }
}