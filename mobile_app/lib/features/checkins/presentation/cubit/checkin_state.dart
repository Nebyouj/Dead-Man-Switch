import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/checkins/presentation/cubit/checkin_operation.dart';

import '../../domain/entities/checkin.dart';

abstract class CheckInState extends Equatable {
  const CheckInState();

  @override
  List<Object?> get props => [];
}

class CheckInInitial extends CheckInState {}

class CheckInLoading extends CheckInState {}

class CheckInsLoaded extends CheckInState {
  final List<CheckIn> checkIns;
  final bool isOperating;
  final String? operationMessage;

  const CheckInsLoaded(
    this.checkIns, {
    this.isOperating = false,
    this.operationMessage,
  });

  CheckInsLoaded copyWith({
    List<CheckIn>? checkIns,
    bool? isOperating,
    String? operationMessage,
    bool clearOperationMessage = false,
  }) {
    return CheckInsLoaded(
      checkIns ?? this.checkIns,
      isOperating: isOperating ?? this.isOperating,
      operationMessage: clearOperationMessage
          ? null
          : operationMessage ?? this.operationMessage,
    );
  }

  @override
  List<Object?> get props => [
        checkIns,
        isOperating,
        operationMessage,
      ];
}

class CheckInLoaded extends CheckInState {
  final CheckIn checkIn;
  final bool isOperating;
  final CheckInOperation? operation;

  const CheckInLoaded(
    this.checkIn, {
    this.isOperating = false,
    this.operation,
  });

  CheckInLoaded copyWith({
    CheckIn? checkIn,
    bool? isOperating,
    CheckInOperation? operation,
    bool clearOperation = false,
  }) {
    return CheckInLoaded(
      checkIn ?? this.checkIn,
      isOperating: isOperating ?? this.isOperating,
      operation: clearOperation ? null : operation ?? this.operation,
    );
  }

  @override
  List<Object?> get props => [
        checkIn,
        isOperating,
        operation,
      ];
}
class CheckInCreated extends CheckInState {
  final CheckIn checkIn;

  const CheckInCreated(this.checkIn);

  @override
  List<Object?> get props => [checkIn];
}

class CheckInDeleted extends CheckInState {
  final int checkInId;

  const CheckInDeleted(this.checkInId);

  @override
  List<Object?> get props => [checkInId];
}

class CheckInUpdated extends CheckInState {
  final CheckIn checkIn;

  const CheckInUpdated(this.checkIn);

  @override
  List<Object?> get props => [checkIn];
}

class CheckInError extends CheckInState {
  final String message;

  const CheckInError(this.message);

  @override
  List<Object?> get props => [message];
}