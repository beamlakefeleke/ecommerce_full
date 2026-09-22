/// Sealed failure hierarchy for error handling across all features.
///
/// Repository implementations catch data-source exceptions and convert
/// them to a typed [Failure]. Usecases and repository interfaces return
/// `Either<Failure, T>` via fpdart — no throwing across the domain boundary.
sealed class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Server responded with an error (4xx, 5xx).
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

/// Device has no network connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Local cache read/write failed.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache operation failed']);
}

/// Authentication-specific failures.
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
