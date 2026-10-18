import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_app/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:mobile_app/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:mobile_app/features/admin/domain/repositories/admin_repostiory.dart';
import 'package:mobile_app/features/admin/domain/usecases/delete_user.dart';
import 'package:mobile_app/features/admin/domain/usecases/force_cancel_checkin.dart';
import 'package:mobile_app/features/admin/domain/usecases/get_admin_stats.dart';
import 'package:mobile_app/features/admin/domain/usecases/get_all_checkin.dart';
import 'package:mobile_app/features/admin/domain/usecases/get_users.dart';
import 'package:mobile_app/features/admin/domain/usecases/update_user_role.dart';
import 'package:mobile_app/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:mobile_app/features/auth/domain/repositories/auth_respository.dart';
import 'package:mobile_app/features/auth/domain/usecases/check_auth_status.dart';
import 'package:mobile_app/features/auth/domain/usecases/get_curent_user.dart';
import 'package:mobile_app/features/checkins/data/datasources/checkin_remote_data_source.dart';
import 'package:mobile_app/features/checkins/data/repositories/checkin_repository_impl.dart';
import 'package:mobile_app/features/checkins/domain/repositories/checkin_repository.dart';
import 'package:mobile_app/features/checkins/domain/usecases/cancel_checkin.dart';
import 'package:mobile_app/features/checkins/domain/usecases/create_checkin.dart';
import 'package:mobile_app/features/checkins/domain/usecases/delete_checkin.dart';
import 'package:mobile_app/features/checkins/domain/usecases/get_checkin.dart';
import 'package:mobile_app/features/checkins/domain/usecases/get_checkins.dart';
import 'package:mobile_app/features/checkins/domain/usecases/reset_checkin.dart';
import 'package:mobile_app/features/checkins/domain/usecases/trigger_checkin.dart';
import 'package:mobile_app/features/checkins/presentation/cubit/checkin_cubit.dart';

import 'core/network/api_client.dart';
import 'core/services/google_sign_in_service.dart';
import 'core/storage/secure_storage.dart';

import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';

import 'features/auth/domain/usecases/google_login.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/logout.dart';
import 'features/auth/domain/usecases/register.dart';

import 'features/auth/presentation/cubit/auth_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  //secure storage

  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<SecureStorage>(
    () => SecureStorage(sl<FlutterSecureStorage>()),
  );

  //Dio
  sl.registerLazySingleton<Dio>(() => Dio());

  // GoogleSignInService
  sl.registerLazySingleton<GoogleSignInService>(
    () => GoogleSignInService(),
  );

  //ApiClient
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(dio: sl<Dio>(), secureStorage: sl<SecureStorage>()),
  );

  // ======================================================
  // Auth - Data
  // ======================================================

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      secureStorage: sl<SecureStorage>(),
    ),
  );

  // ======================================================
  // Auth - Use Cases
  // ======================================================

  sl.registerLazySingleton<Login>(() => Login(sl<AuthRepository>()));
  sl.registerLazySingleton<Register>(() => Register(sl<AuthRepository>()));
  sl.registerLazySingleton<GoogleLogin>(
    () => GoogleLogin(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetCurrentUser>(
    () => GetCurrentUser(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<Logout>(() => Logout(sl<AuthRepository>()));
  sl.registerLazySingleton<CheckAuthStatus>(
    () => CheckAuthStatus(sl<AuthRepository>()),
  );

  // ======================================================
  // Auth - Presentation
  // ======================================================

  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      login: sl<Login>(),
      register: sl<Register>(),
      googleLogin: sl<GoogleLogin>(),
      googleSignInService: sl<GoogleSignInService>(),
      getCurrentUser: sl<GetCurrentUser>(),
      logout: sl<Logout>(),
      checkAuthStatus: sl<CheckAuthStatus>(),
    ),
  );

  // ======================================================
  // check-ins -- Data
  // ======================================================

  sl.registerLazySingleton<CheckInRemoteDataSource>(
    () => CheckInRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<CheckInRepository>(
    () =>
        CheckInRepositoryImpl(remoteDataSource: sl<CheckInRemoteDataSource>()),
  );

  // ======================================================
  // check-ins -- usecase
  // ======================================================

  sl.registerLazySingleton<GetCheckIns>(
    () => GetCheckIns(sl<CheckInRepository>()),
  );

  sl.registerLazySingleton<GetCheckIn>(
    () => GetCheckIn(sl<CheckInRepository>()),
  );

  sl.registerLazySingleton<CreateCheckIn>(
    () => CreateCheckIn(sl<CheckInRepository>()),
  );

  sl.registerLazySingleton<DeleteCheckIn>(
    () => DeleteCheckIn(sl<CheckInRepository>()),
  );

  sl.registerLazySingleton<ResetCheckIn>(
    () => ResetCheckIn(sl<CheckInRepository>()),
  );
  sl.registerLazySingleton<CancelCheckIn>(
    () => CancelCheckIn(sl<CheckInRepository>()),
  );
  sl.registerLazySingleton<TriggerCheckIn>(
    () => TriggerCheckIn(sl<CheckInRepository>()),
  );

  // ======================================================
  // check-ins -- presentation
  // ======================================================

  sl.registerFactory<CheckInCubit>(
    () => CheckInCubit(
      getCheckIns: sl<GetCheckIns>(),
      getCheckIn: sl<GetCheckIn>(),
      createCheckIn: sl<CreateCheckIn>(),
      deleteCheckIn: sl<DeleteCheckIn>(),
      resetCheckIn: sl<ResetCheckIn>(),
      cancelCheckIn: sl<CancelCheckIn>(),
      triggerCheckIn: sl<TriggerCheckIn>(),
    ),
  );

  // ==================== ADMIN ====================

  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(sl<AdminRemoteDataSource>()),
  );

  sl.registerLazySingleton<GetAdminStats>(
    () => GetAdminStats(sl<AdminRepository>()),
  );

  sl.registerLazySingleton<GetUsers>(() => GetUsers(sl<AdminRepository>()));

  sl.registerLazySingleton<GetAllCheckin>(
    () => GetAllCheckin(sl<AdminRepository>()),
  );

  sl.registerLazySingleton<ForceCancelCheckin>(
    () => ForceCancelCheckin(sl<AdminRepository>()),
  );

  sl.registerLazySingleton<DeleteUser>(() => DeleteUser(sl<AdminRepository>()));

  sl.registerLazySingleton<UpdateUserRole>(
    () => UpdateUserRole(sl<AdminRepository>()),
  );

  sl.registerFactory<AdminCubit>(
    () => AdminCubit(
      getAdminStats: sl<GetAdminStats>(),
      getUsers: sl<GetUsers>(),
      getAllCheckin: sl<GetAllCheckin>(),
      forceCancelCheckin: sl<ForceCancelCheckin>(),
      deleteUser: sl<DeleteUser>(),
      updateUserRole: sl<UpdateUserRole>(),
    ),
  );
}
