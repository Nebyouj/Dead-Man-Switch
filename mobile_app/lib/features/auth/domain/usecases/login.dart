import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_respository.dart';

class Login {
  final AuthRepository respository;

  Login(this.respository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) {
    return respository.login(email: email, password: password);
  }
}
