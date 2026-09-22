import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/profile/domain/entities/user_info.dart';
import 'package:ecommerce/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetUserInfoUseCase {
  final ProfileRepository repository;

  GetUserInfoUseCase(this.repository);

  Future<Either<Failure, UserInfo>> call() {
    return repository.getUserInfo();
  }
}
