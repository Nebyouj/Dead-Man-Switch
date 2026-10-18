import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/checkins/domain/entities/checkin_status.dart';
import 'package:mobile_app/features/checkins/domain/entities/notification_channel.dart';


class CheckIn extends Equatable {
  final int id;
  final String name;
  final String? message;
  final String? recipientEmail;
  final String? recipientPhone;
  final List<NotificationChannel> channels;
  final int durationMinutes;
  final DateTime deadline;
  final CheckInStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? triggeredAt;

  const CheckIn({
    required this.id,
    required this.name,
    this.message,
    this.recipientEmail,
    this.recipientPhone,
    required this.channels,
    required this.durationMinutes,
    required this.deadline,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.triggeredAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    message,
    recipientEmail,
    recipientPhone,
    channels,
    durationMinutes,
    deadline,
    status,
    createdAt,
    updatedAt,
    triggeredAt
  ];
}

