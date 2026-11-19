import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/common/models/response_model.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/profile/domain/models/userinfo_model.dart';
import 'package:ecommerce/features/profile/domain/repositories/profile_repository.dart';

class GetUserInfoUseCase implements UseCase<UserInfoModel, NoParams> {
  final ProfileRepository repository;
  GetUserInfoUseCase(this.repository);

  @override
  Future<Either<Failure, UserInfoModel>> call(NoParams params) =>
      repository.getUserInfo();
}

/// Params for a profile update: the edited fields plus the optional picked
/// image file.
class UpdateProfileParams {
  final UserInfoModel userInfoModel;
  final XFile? pickedImage;

  const UpdateProfileParams({required this.userInfoModel, this.pickedImage});
}

class UpdateProfileUseCase implements UseCase<ResponseModel, UpdateProfileParams> {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ResponseModel>> call(UpdateProfileParams params) =>
      repository.updateProfile(params.userInfoModel, params.pickedImage);
}

class ChangePasswordUseCase implements UseCase<ResponseModel, UserInfoModel> {
  final ProfileRepository repository;
  ChangePasswordUseCase(this.repository);

  @override
  Future<Either<Failure, ResponseModel>> call(UserInfoModel params) =>
      repository.changePassword(params);
}

class DeleteUserUseCase implements UseCase<ResponseModel, NoParams> {
  final ProfileRepository repository;
  DeleteUserUseCase(this.repository);

  @override
  Future<Either<Failure, ResponseModel>> call(NoParams params) =>
      repository.deleteUser();
}
