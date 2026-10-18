import 'package:dartz/dartz.dart';
import 'package:mobile_app/features/checkins/domain/entities/notification_channel.dart';

import '../../../../core/error/failures.dart';
import '../entities/checkin.dart';

abstract class CheckInRepository {
  Future<Either<Failure, List<CheckIn>>> getCheckIns();

  Future<Either<Failure, CheckIn>> getCheckIn({required int checkInId});

  Future<Either<Failure, CheckIn>> createCheckIn({
    required String name,
    String? message,
    String? recipientEmail,
    String? recipientPhone,
    required List<NotificationChannel> channels,
    required int durationMinutes,
  });

  Future<Either<Failure, void>> deleteCheckIn({required int checkInId});

  Future<Either<Failure, CheckIn>> resetCheckIn({required int checkInId});

  Future<Either<Failure, CheckIn>> cancelCheckIn({required int checkInId});

  Future<Either<Failure, CheckIn>> triggerCheckIn({required int checkInId});
  
}
