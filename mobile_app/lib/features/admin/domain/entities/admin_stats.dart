import 'package:equatable/equatable.dart';

class AdminStats extends Equatable {
  final int totalUsers;
  final int totalActiveCheckIns;
  final int totalTriggeredCheckIns;

  const AdminStats({
    required this.totalUsers,
    required this.totalActiveCheckIns,
    required this.totalTriggeredCheckIns,
  });

  @override
  List<Object?> get props => [
        totalUsers,
        totalActiveCheckIns,
        totalTriggeredCheckIns,
      ];
}