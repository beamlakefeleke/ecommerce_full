import 'package:equatable/equatable.dart';

/// Base class for all failures that cross the domain boundary.
///
/// Repositories convert exceptions / non-200 responses from the data layer
/// into one of these, and return `Either<Failure, T>`. The UI never sees a raw
/// exception.
sealed class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Backend returned an error (non-200) or an unexpected payload.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// No connectivity / request could not reach the server.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Local cache / shared preferences read-write failure.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

/// Any other unexpected failure.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Something went wrong']);
}
