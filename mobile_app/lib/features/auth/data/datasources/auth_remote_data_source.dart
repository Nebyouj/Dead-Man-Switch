import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/token_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  AuthRemoteDataSource(ApiClient apiClient);

  Future<UserModel> register({required String email, required String password});

  Future<TokenModel> login({required String email, required String password});

  Future<TokenModel> googleLogin({required String idToken});

  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  const AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserModel> register({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.register,
      data: {'email': email, 'password': password},
    );
    return UserModel.fromJson(response.data!);
  }

  @override
  Future<TokenModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.postForm<Map<String, dynamic>>(
      ApiConstants.login,
      data: {'username': email, 'password': password},
    );
    return TokenModel.fromJson(response.data!);
  }

  @override
  Future<TokenModel> googleLogin({required String idToken}) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.googleLogin,
      data: {'id_token': idToken},
    );
    return TokenModel.fromJson(response.data!);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.me,
    );
    return UserModel.fromJson(response.data!);
  }
}
