import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/profile/domain/entities/user_info.dart';
import 'package:ecommerce/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, UserInfo>> call(UserInfo userInfo, XFile? avatar, String token) {
    return repository.updateProfile(userInfo, avatar, token);
  }
}
