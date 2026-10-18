class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://192.168.10.21:8000';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleLogin = '/auth/google';
  static const String me = '/auth/me';

  // Check-ins
  static const String checkins = '/checkins';

  // Admin
  static const String adminUsers = '/admin/users';
  static const String adminCheckins = '/admin/checkins';
  static const String adminStats = '/admin/stats';

  // Storage
  static const String accessToken = 'access_token';
}