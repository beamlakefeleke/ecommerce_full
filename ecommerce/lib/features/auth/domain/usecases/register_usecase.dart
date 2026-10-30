import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/auth/domain/entities/auth_response.dart';
import 'package:ecommerce/features/auth/domain/entities/sign_up_params.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';

class RegisterParams extends Equatable {
  final SignUpParams signUp;
  final bool isCustomerVerificationOn;

  const RegisterParams({
    required this.signUp,
    required this.isCustomerVerificationOn,
  });

  @override
  List<Object?> get props => [signUp, isCustomerVerificationOn];
}

class RegisterUseCase implements UseCase<AuthResponse, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(RegisterParams params) {
    return repository.register(params.signUp, params.isCustomerVerificationOn);
  }
}
