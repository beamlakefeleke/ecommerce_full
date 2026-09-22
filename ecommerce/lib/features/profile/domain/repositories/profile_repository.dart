import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/profile/domain/entities/user_info.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';

abstract class ProfileRepository {
  /// Fetches the user's profile information.
  Future<Either<Failure, UserInfo>> getUserInfo();

  /// Updates the user's profile information, optionally uploading a new avatar image.
  Future<Either<Failure, UserInfo>> updateProfile(UserInfo userInfo, XFile? avatar, String token);

  /// Changes the user's password.
  Future<Either<Failure, void>> changePassword(UserInfo userInfo);

  /// Deletes the user's account.
  Future<Either<Failure, void>> deleteUser();
}