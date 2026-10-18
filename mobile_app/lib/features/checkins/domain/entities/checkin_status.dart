enum CheckInStatus { active, triggered, cancelled }

extension CheckInStatusX on CheckInStatus {
  String get value {
    switch (this) {
      case CheckInStatus.active:
        return 'ACTIVE';
      case CheckInStatus.triggered:
        return 'TRIGGERED';
      case CheckInStatus.cancelled:
        return 'CANCELLED';
    }
  }

  static CheckInStatus fromValue(String value) {
    switch (value) {
      case 'ACTIVE':
        return CheckInStatus.active;
      case 'TRIGGERED':
        return CheckInStatus.triggered;
      case 'CANCELLED':
        return CheckInStatus.cancelled;
      default:
        throw ArgumentError('Unknown check-in status: $value');
    }
  }
}
