import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/common/models/response_model.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/profile/domain/models/userinfo_model.dart';

/// Abstract contract for the profile feature. Returns `Either<Failure, T>`;
/// raw exceptions never cross this boundary.
abstract class ProfileRepository {
  Future<Either<Failure, UserInfoModel>> getUserInfo();
  Future<Either<Failure, ResponseModel>> updateProfile(
    UserInfoModel userInfoModel,
    XFile? pickedImage,
  );
  Future<Either<Failure, ResponseModel>> changePassword(
    UserInfoModel userInfoModel,
  );
  Future<Either<Failure, ResponseModel>> deleteUser();
}
