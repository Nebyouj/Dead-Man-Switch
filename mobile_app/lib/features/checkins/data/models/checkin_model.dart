import '../../domain/entities/checkin.dart';
import '../../domain/entities/checkin_status.dart';
import '../../domain/entities/notification_channel.dart';

class CheckInModel extends CheckIn {
  const CheckInModel({
    required super.id,
    required super.name,
    super.message,
    super.recipientEmail,
    super.recipientPhone,
    required super.channels,
    required super.durationMinutes,
    required super.deadline,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.triggeredAt,
  });

  static DateTime _parseDateTime(String? dateString) {
    if (dateString == null) return DateTime.now();
    final parsed = DateTime.parse(dateString);
    // DateTime.parse returns isUtc=true only if the string has 'Z' or an offset.
    // If it parsed as local (no timezone info), reinterpret as UTC.
    if (!parsed.isUtc) {
      return DateTime.utc(
        parsed.year, parsed.month, parsed.day,
        parsed.hour, parsed.minute, parsed.second,
        parsed.millisecond, parsed.microsecond,
      ).toLocal();
    }
    return parsed.toLocal();
  }

  factory CheckInModel.fromJson(Map<String, dynamic> json) {
    return CheckInModel(
      id: json['id'] as int,
      name: json['name'] as String,
      message: json['message'] as String?,
      recipientEmail: json['recipient_email'] as String?,
      recipientPhone: json['recipient_phone'] as String?,
      channels: (json['channels'] as List<dynamic>)
          .map((channel) => NotificationChannelX.fromValue(channel as String))
          .toList(),
      durationMinutes: json['duration_minutes'] as int,
      deadline: _parseDateTime(json['deadline'] as String?),
      status: CheckInStatusX.fromValue(json['status'] as String),
      createdAt: _parseDateTime(json['created_at'] as String?),
      updatedAt: _parseDateTime(json['updated_at'] as String?),
      triggeredAt: json['triggered_at'] == null
          ? null
          : _parseDateTime(json['triggered_at'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'message': message,
      'recipient_email': recipientEmail,
      'recipient_phone': recipientPhone,
      'channels': channels.map((channel) => channel.value).toList(),
      'duration_minutes': durationMinutes,
      'deadline': deadline.toUtc().toIso8601String(),
      'status': status.value,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'triggered_at': triggeredAt?.toUtc().toIso8601String(),
    };
  }
}
