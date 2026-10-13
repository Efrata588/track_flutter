sealed class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class ValidationException extends ApiException {
  final Map<String, List<String>> errors;
  const ValidationException(
    super.message, {
    this.errors = const {},
  });

  String? firstErrorFor(String field) => errors[field]?.firstOrNull;
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    super.message = 'Please log in to continue.',
  ]);
}

class ForbiddenException extends ApiException {
  final bool isUnverifiedEmail;
  const ForbiddenException({
    String message = "Your email isn't verified. Verify it from the web app, then log in again.",
    this.isUnverifiedEmail = false,
  }) : super(message);
}

class ThrottledException extends ApiException {
  const ThrottledException([
    super.message = 'Too many attempts, try again in a minute.',
  ]);
}

class NetworkException extends ApiException {
  const NetworkException([
    super.message = 'Unable to connect to the server. Please check your connection.',
  ]);
}

class ServerException extends ApiException {
  final int? statusCode;
  const ServerException([
    super.message = 'Something went wrong on the server.',
    this.statusCode,
  ]);
}
