import '../../domain/entities/admin_stats.dart';

class AdminStatsModel extends AdminStats {
  const AdminStatsModel({
    required super.totalUsers,
    required super.totalActiveCheckIns,
    required super.totalTriggeredCheckIns,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalUsers: json['total_users'] as int,
      totalActiveCheckIns: json['total_active_checkins'] as int,
      totalTriggeredCheckIns: json['total_triggered_checkins'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'total_active_checkins': totalActiveCheckIns,
      'total_triggered_checkins': totalTriggeredCheckIns,
    };
  }
}
