import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/google_sign_in_service.dart';
import '../../domain/usecases/get_curent_user.dart';
import '../../domain/usecases/google_login.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/check_auth_status.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final Login login;
  final Register register;
  final GoogleLogin googleLogin;
  final GoogleSignInService googleSignInService;
  final Logout logout;
  final GetCurrentUser getCurrentUser;
  final CheckAuthStatus checkAuthStatus;

  AuthCubit({
    required this.login,
    required this.register,
    required this.googleLogin,
    required this.googleSignInService,
    required this.logout,
    required this.getCurrentUser,
    required this.checkAuthStatus,
  }) : super(AuthInitial());

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    final result = await login(email: email, password: password);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> registerUser({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    final result = await register(email: email, password: password);

    result.fold(
      (failure) {
        emit(AuthError(failure.message));
      },
      (user) {
        emit(AuthRegistrationSuccess(email));
      },
    );
  }

  /// Initiates the full Google Sign-In flow:
  /// 1. Opens the native Google Sign-In UI to obtain an `idToken`.
  /// 2. Sends the `idToken` to the backend via the [GoogleLogin] use case.
  Future<void> googleLoginUser() async {
    emit(AuthLoading());

    try {
      final idToken = await googleSignInService.signIn();

      if (idToken == null) {
        // User cancelled the Google Sign-In dialog
        emit(AuthUnAuthenticated());
        return;
      }

      final result = await googleLogin(idToken: idToken);

      result.fold(
        (failure) {
          emit(AuthError(failure.message));
        },
        (user) {
          emit(AuthAuthenticated(user));
        },
      );
    } catch (e) {
      emit(AuthError('Google Sign-In failed. Please try again.'));
    }
  }

  Future<void> checkAuthenticationStatus() async {
    emit(AuthLoading());

    final result = await checkAuthStatus();

    result.fold(
      (_) {
        emit(AuthUnAuthenticated());
      },
      (user) {
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> logoutUser() async {
    emit(AuthLoading());

    // Sign out of Google as well to clear the cached account
    await googleSignInService.signOut();

    final result = await logout();

    result.fold(
      (failure) {
        emit(AuthError(failure.message));
      },
      (_) {
        emit(AuthInitial());
      },
    );
  }
}

