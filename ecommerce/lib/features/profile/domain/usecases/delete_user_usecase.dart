import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteUserUseCase {
  final ProfileRepository repository;

  DeleteUserUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.deleteUser();
  }
}
