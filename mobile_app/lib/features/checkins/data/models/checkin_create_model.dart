import '../../domain/entities/notification_channel.dart';

class CheckInCreateModel {
  final String name;
  final String? message;
  final String? recipientEmail;
  final String? recipientPhone;
  final List<NotificationChannel> channels;
  final int durationMinutes;

  const CheckInCreateModel({
    required this.name,
    this.message,
    this.recipientEmail,
    this.recipientPhone,
    required this.channels,
    required this.durationMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'message': message,
      'recipient_email': recipientEmail,
      'recipient_phone': recipientPhone,
      'channels': channels
          .map((channel) => channel.value)
          .toList(),
      'duration_minutes': durationMinutes,
    };
  }
}