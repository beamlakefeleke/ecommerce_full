import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';

/// Obtains a guest session ID from the server.
class GuestLoginUseCase {
  final AuthRepository _repository;

  const GuestLoginUseCase(this._repository);

  Future<Either<Failure, String>> call() {
    return _repository.guestLogin();
  }
}
