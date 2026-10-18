import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/checkin.dart';
import '../../domain/entities/notification_channel.dart';
import '../../domain/repositories/checkin_repository.dart';
import '../datasources/checkin_remote_data_source.dart';
import '../models/checkin_create_model.dart';

class CheckInRepositoryImpl implements CheckInRepository {
  final CheckInRemoteDataSource remoteDataSource;

  const CheckInRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<CheckIn>>> getCheckIns() async {
    try {
      final checkIns = await remoteDataSource.getCheckIns();

      return Right(checkIns);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure(e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, CheckIn>> getCheckIn({
    required int checkInId,
  }) async {
    try {
      final checkIn = await remoteDataSource.getCheckIn(
        checkInId: checkInId,
      );

      return Right(checkIn);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CheckIn>> createCheckIn({
    required String name,
    String? message,
    String? recipientEmail,
    String? recipientPhone,
    required List<NotificationChannel> channels,
    required int durationMinutes,
  }) async {
    try {
      final model = CheckInCreateModel(
        name: name,
        message: message,
        recipientEmail: recipientEmail,
        recipientPhone: recipientPhone,
        channels: channels,
        durationMinutes: durationMinutes,
      );

      final checkIn = await remoteDataSource.createCheckIn(
        checkIn: model,
      );

      return Right(checkIn);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCheckIn({
    required int checkInId,
  }) async {
    try {
      await remoteDataSource.deleteCheckIn(
        checkInId: checkInId,
      );

      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CheckIn>> resetCheckIn({
    required int checkInId,
  }) async {
    try {
      final checkIn = await remoteDataSource.resetCheckIn(
        checkInId: checkInId,
      );

      return Right(checkIn);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CheckIn>> cancelCheckIn({
    required int checkInId,
  }) async {
    try {
      final checkIn = await remoteDataSource.cancelCheckIn(
        checkInId: checkInId,
      );

      return Right(checkIn);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CheckIn>> triggerCheckIn({
    required int checkInId,
  }) async {
    try {
      final checkIn = await remoteDataSource.triggerCheckIn(
        checkInId: checkInId,
      );

      return Right(checkIn);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}