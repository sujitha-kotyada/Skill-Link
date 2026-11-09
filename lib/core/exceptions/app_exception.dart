class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.details});
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code, super.details});
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.details});
}

class PermissionException extends AppException {
  const PermissionException(super.message, {super.code, super.details});
}

class ProfileNotFoundException extends AppException {
  const ProfileNotFoundException(super.message, {super.code, super.details});
}

class AccountSuspendedException extends AppException {
  const AccountSuspendedException(super.message, {super.code, super.details});
}

class PartialRegistrationException extends AppException {
  const PartialRegistrationException(super.message, {super.code, super.details});
}

