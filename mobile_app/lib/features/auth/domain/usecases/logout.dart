import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_respository.dart';

class Logout {
  final AuthRepository respository;

  Logout(this.respository);

  Future<Either<Failure, void>> call() {
    return respository.logout();
  }
}