import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/auth/domain/entities/social_sign_in_params.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';

class SocialRegisterParams extends Equatable {
  final SocialSignInParams social;
  final bool isCustomerVerificationOn;

  const SocialRegisterParams({
    required this.social,
    required this.isCustomerVerificationOn,
  });

  @override
  List<Object?> get props => [social, isCustomerVerificationOn];
}

class SocialRegisterUseCase
    implements UseCase<SocialAuthResult, SocialRegisterParams> {
  final AuthRepository repository;

  SocialRegisterUseCase(this.repository);

  @override
  Future<Either<Failure, SocialAuthResult>> call(SocialRegisterParams params) {
    return repository.registerWithSocialMedia(
      params.social,
      params.isCustomerVerificationOn,
    );
  }
}
