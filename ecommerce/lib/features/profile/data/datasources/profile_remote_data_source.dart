import 'package:get/get_connect/connect.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/common/models/response_model.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/profile/domain/models/userinfo_model.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Raw API access for the profile feature. Throws [ServerException] /
/// [NetworkException]; the repository converts these to [Failure]s.
abstract class ProfileRemoteDataSource {
  Future<UserInfoModel> getUserInfo();
  Future<ResponseModel> updateProfile(UserInfoModel userInfoModel, XFile? data);
  Future<ResponseModel> changePassword(UserInfoModel userInfoModel);
  Future<ResponseModel> deleteUser();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserInfoModel> getUserInfo() async {
    final Response response = await apiClient.getData(
      AppConstants.customerInfoUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return UserInfoModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<ResponseModel> updateProfile(
    UserInfoModel userInfoModel,
    XFile? data,
  ) async {
    final Map<String, String> body = {
      'f_name': userInfoModel.fName!,
      'l_name': userInfoModel.lName!,
      'email': userInfoModel.email!,
    };
    final Response response = await apiClient.postMultipartData(
      AppConstants.updateProfileUri,
      body,
      [MultipartBody('image', data)],
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ResponseModel(true, response.bodyString);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<ResponseModel> changePassword(UserInfoModel userInfoModel) async {
    final Map<String, dynamic> body = {
      'f_name': userInfoModel.fName,
      'l_name': userInfoModel.lName,
      'email': userInfoModel.email,
      'password': userInfoModel.password,
    };
    final Response response = await apiClient.postData(
      AppConstants.updateProfileUri,
      body,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ResponseModel(true, response.body["message"]);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<ResponseModel> deleteUser() async {
    final Response response = await apiClient.deleteData(
      AppConstants.customerRemoveUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ResponseModel(true, 'your_account_remove_successfully'.tr);
    }
    throw _exceptionFor(response);
  }

  Exception _exceptionFor(Response response) {
    // statusCode 0/1 are the ApiClient's "no internet" sentinels.
    if (response.statusCode == null ||
        response.statusCode == 0 ||
        response.statusCode == 1) {
      return NetworkException(response.statusText ?? 'No internet connection');
    }
    return ServerException(response.statusText ?? 'Server error');
  }
}
