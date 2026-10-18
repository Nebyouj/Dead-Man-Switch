import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_respository.dart';

class GoogleLogin {
  final AuthRepository respository;

  GoogleLogin(this.respository);

  Future<Either<Failure, User>> call({required String idToken}) {
    return respository.googleLogin(idToken: idToken);
  }
}