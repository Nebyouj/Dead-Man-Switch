import 'package:dartz/dartz.dart';
import 'package:mobile_app/features/checkins/domain/entities/notification_channel.dart';

import '../../../../core/error/failures.dart';
import '../entities/checkin.dart';
import '../repositories/checkin_repository.dart';

class CreateCheckIn {
  final CheckInRepository repository;

  const CreateCheckIn(this.repository);

  Future<Either<Failure, CheckIn>> call({
    required String name,
    String? message,
    String? recipientEmail,
    String? recipientPhone,
    required List<NotificationChannel> channels,
    required int durationMinutes,
  }) {
    return repository.createCheckIn(
      name: name,
      message: message,
      recipientEmail: recipientEmail,
      recipientPhone: recipientPhone,
      channels: channels,
      durationMinutes: durationMinutes,
    );
  }
}
