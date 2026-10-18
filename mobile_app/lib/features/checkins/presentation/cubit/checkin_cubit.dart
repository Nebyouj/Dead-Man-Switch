import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/checkins/presentation/cubit/checkin_operation.dart';

import '../../domain/entities/notification_channel.dart';
import '../../domain/usecases/cancel_checkin.dart';
import '../../domain/usecases/create_checkin.dart';
import '../../domain/usecases/delete_checkin.dart';
import '../../domain/usecases/get_checkin.dart';
import '../../domain/usecases/get_checkins.dart';
import '../../domain/usecases/reset_checkin.dart';
import '../../domain/usecases/trigger_checkin.dart';
import 'checkin_state.dart';

class CheckInCubit extends Cubit<CheckInState> {
  final GetCheckIns getCheckIns;
  final GetCheckIn getCheckIn;
  final CreateCheckIn createCheckIn;
  final DeleteCheckIn deleteCheckIn;
  final ResetCheckIn resetCheckIn;
  final CancelCheckIn cancelCheckIn;
  final TriggerCheckIn triggerCheckIn;

  CheckInCubit({
    required this.getCheckIns,
    required this.getCheckIn,
    required this.createCheckIn,
    required this.deleteCheckIn,
    required this.resetCheckIn,
    required this.cancelCheckIn,
    required this.triggerCheckIn,
  }) : super(CheckInInitial());

  Future<void> loadCheckIns() async {
    final currentState = state;

    if (currentState is! CheckInsLoaded) {
      emit(CheckInLoading());
    }

    final result = await getCheckIns();

    result.fold(
      (failure) {
        if (currentState is CheckInsLoaded) {
          emit(
            currentState.copyWith(
              isOperating: false,
              operationMessage: failure.message,
            ),
          );
        } else {
          emit(CheckInError(failure.message));
        }
      },
      (checkIns) {
        emit(CheckInsLoaded(checkIns, isOperating: false));
      },
    );
  }

  Future<void> loadCheckIn({required int checkInId}) async {
    final currentState = state;

    if (currentState is! CheckInLoaded) {
      emit(CheckInLoading());
    }

    final result = await getCheckIn(checkInId: checkInId);

    result.fold(
      (failure) {
        if (currentState is CheckInLoaded) {
          emit(currentState.copyWith(isOperating: false, clearOperation: true));
        } else {
          emit(CheckInError(failure.message));
        }
      },
      (checkIn) {
        emit(CheckInLoaded(checkIn, isOperating: false));
      },
    );
  }

  Future<void> create({
    required String name,
    String? message,
    String? recipientEmail,
    String? recipientPhone,
    required List<NotificationChannel> channels,
    required int durationMinutes,
  }) async {
    emit(CheckInLoading());

    final result = await createCheckIn(
      name: name,
      message: message,
      recipientEmail: recipientEmail,
      recipientPhone: recipientPhone,
      channels: channels,
      durationMinutes: durationMinutes,
    );

    result.fold(
      (failure) {
        emit(CheckInError(failure.message));
      },
      (checkIn) {
        emit(CheckInCreated(checkIn));
      },
    );
  }

  Future<void> delete({required int checkInId}) async {
    final currentState = state;

    if (currentState is! CheckInLoaded) {
      return;
    }

    emit(
      currentState.copyWith(
        isOperating: true,
        operation: CheckInOperation.delete,
      ),
    );

    final result = await deleteCheckIn(checkInId: checkInId);

    result.fold(
      (failure) {
        emit(currentState.copyWith(isOperating: false, clearOperation: true));

        emit(CheckInError(failure.message));
      },
      (_) {
        emit(CheckInDeleted(checkInId));
      },
    );
  }

  Future<void> reset({required int checkInId}) async {
    final currentState = state;

    if (currentState is! CheckInLoaded) {
      return;
    }

    emit(
      currentState.copyWith(
        isOperating: true,
        operation: CheckInOperation.checkIn,
      ),
    );

    final result = await resetCheckIn(checkInId: checkInId);

    result.fold(
      (failure) {
        emit(currentState.copyWith(isOperating: false, clearOperation: true));

        emit(CheckInError(failure.message));
      },
      (checkIn) {
        emit(CheckInLoaded(checkIn, isOperating: false));
      },
    );
  }

  Future<void> cancel({required int checkInId}) async {
    final currentState = state;

    if (currentState is! CheckInLoaded) {
      return;
    }

    emit(
      currentState.copyWith(
        isOperating: true,
        operation: CheckInOperation.cancel,
      ),
    );

    final result = await cancelCheckIn(checkInId: checkInId);

    result.fold(
      (failure) {
        emit(currentState.copyWith(isOperating: false, clearOperation: true));

        emit(CheckInError(failure.message));
      },
      (checkIn) {
        emit(CheckInLoaded(checkIn, isOperating: false));
      },
    );
  }

  Future<void> trigger({required int checkInId}) async {
    final currentState = state;

    if (currentState is! CheckInLoaded) {
      return;
    }

    emit(
      currentState.copyWith(
        isOperating: true,
        operation: CheckInOperation.trigger,
      ),
    );

    final result = await triggerCheckIn(checkInId: checkInId);

    result.fold(
      (failure) {
        emit(currentState.copyWith(isOperating: false, clearOperation: true));

        emit(CheckInError(failure.message));
      },
      (checkIn) {
        emit(CheckInLoaded(checkIn, isOperating: false));
      },
    );
  }
}
