import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/auth/domain/entities/auth_response.dart';
import 'package:ecommerce/features/auth/domain/entities/signup_body.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';

/// Registers a new customer account.
///
/// On success with verification disabled, saves the token and clears
/// the guest ID automatically through the repository.
class RegisterUseCase {
  final AuthRepository _repository;

  const RegisterUseCase(this._repository);

  Future<Either<Failure, AuthResponse>> call(SignupBody body) {
    return _repository.register(body);
  }
}
