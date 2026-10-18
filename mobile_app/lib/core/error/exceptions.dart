class ServerException implements Exception {
  final String message;

  const ServerException([this.message = 'Something went wrong on the server.']);
}

class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'Unable to connect to the server.']);
}

class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException([this.message = 'Unauthorized request.']);
}

class NotFoundException implements Exception {
  final String message;

  const NotFoundException([this.message = 'Resource not found.']);
}

class ValidationException implements Exception {
  final String message;

  const ValidationException([this.message = 'Invalid request.']);
}

class UnknownException implements Exception {
  final String message;

  const UnknownException ([this.message = 'An unexpected error occurred']);
}
