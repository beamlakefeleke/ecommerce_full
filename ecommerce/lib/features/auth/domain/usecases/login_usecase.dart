import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/auth/domain/entities/auth_response.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';

class LoginParams extends Equatable {
  final String? phone;
  final String? password;
  final bool isCustomerVerificationOn;

  const LoginParams({
    required this.phone,
    required this.password,
    required this.isCustomerVerificationOn,
  });

  @override
  List<Object?> get props => [phone, password, isCustomerVerificationOn];
}

class LoginUseCase implements UseCase<AuthResponse, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(LoginParams params) {
    return repository.login(
      phone: params.phone,
      password: params.password,
      isCustomerVerificationOn: params.isCustomerVerificationOn,
    );
  }
}
