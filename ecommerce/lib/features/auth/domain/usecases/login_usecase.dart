import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/auth/domain/entities/auth_response.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';

/// Authenticates a user via phone number and password.
class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<Either<Failure, AuthResponse>> call({
    required String phone,
    required String password,
  }) {
    return _repository.login(phone: phone, password: password);
  }
}
