enum NotificationChannel {
  email,
  sms,
}

extension NotificationChannelX on NotificationChannel {
  String get value {
    switch (this) {
      case NotificationChannel.email:
        return 'email';
      case NotificationChannel.sms:
        return 'sms';
    }
  }

  static NotificationChannel fromValue(String value) {
    switch (value) {
      case 'email':
        return NotificationChannel.email;
      case 'sms':
        return NotificationChannel.sms;
      default:
        throw ArgumentError(
          'Unknown notification channel: $value',
        );
    }
  }
}