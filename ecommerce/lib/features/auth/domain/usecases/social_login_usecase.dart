import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/auth/domain/entities/social_sign_in_params.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';

class SocialLoginParams extends Equatable {
  final SocialSignInParams social;
  final int timeout;
  final bool isCustomerVerificationOn;

  const SocialLoginParams({
    required this.social,
    this.timeout = 60,
    required this.isCustomerVerificationOn,
  });

  @override
  List<Object?> get props => [social, timeout, isCustomerVerificationOn];
}

class SocialLoginUseCase implements UseCase<SocialAuthResult, SocialLoginParams> {
  final AuthRepository repository;

  SocialLoginUseCase(this.repository);

  @override
  Future<Either<Failure, SocialAuthResult>> call(SocialLoginParams params) {
    return repository.loginWithSocialMedia(
      params.social,
      params.timeout,
      params.isCustomerVerificationOn,
    );
  }
}
