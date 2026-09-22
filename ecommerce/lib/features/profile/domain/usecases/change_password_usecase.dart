import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/profile/domain/entities/user_info.dart';
import 'package:ecommerce/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class ChangePasswordUseCase {
  final ProfileRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(UserInfo userInfo) {
    return repository.changePassword(userInfo);
  }
}
