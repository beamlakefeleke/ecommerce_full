import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';

class GuestLoginUseCase implements UseCase<String, NoParams> {
  final AuthRepository repository;

  GuestLoginUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) {
    return repository.guestLogin();
  }
}
