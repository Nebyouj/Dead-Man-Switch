import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_respository.dart';

class Register {
  final AuthRepository respository;

  Register(this.respository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) {
    return respository.register(email: email, password: password);
  }
}