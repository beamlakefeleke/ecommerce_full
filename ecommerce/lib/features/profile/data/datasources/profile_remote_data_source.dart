import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/common/models/response_model.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/profile/data/models/userinfo_model.dart';
import 'package:ecommerce/features/profile/domain/entities/user_info.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSource({required this.apiClient});

  Future<UserInfoModel?> getUserInfo() async {
    Response response = await apiClient.getData(AppConstants.customerInfoUri);
    if (response.statusCode == 200) {
      return UserInfoModel.fromJson(response.body);
    }
    throw ServerFailure(response.statusText ?? 'Failed to get user info');
  }

  Future<ResponseModel> updateProfile(UserInfo userInfo, XFile? avatar, String token) async {
    Map<String, String> body = {
      'f_name': userInfo.fName ?? '',
      'l_name': userInfo.lName ?? '',
      'email': userInfo.email ?? '',
    };

    Response response = await apiClient.postMultipartData(
      AppConstants.updateProfileUri,
      body,
      [if (avatar != null) MultipartBody('image', avatar)],
      handleError: false,
    );
    
    if (response.statusCode == 200) {
      return ResponseModel(true, response.bodyString);
    } else {
      throw ServerFailure(response.statusText ?? 'Failed to update profile');
    }
  }

  Future<ResponseModel> changePassword(UserInfo userInfo) async {
    Map<String, dynamic> body = {
      'f_name': userInfo.fName,
      'l_name': userInfo.lName,
      'email': userInfo.email,
      'password': userInfo.password,
    };
    
    Response response = await apiClient.postData(AppConstants.updateProfileUri, body, handleError: false);
    if (response.statusCode == 200) {
      return ResponseModel(true, response.body["message"]);
    } else {
      throw ServerFailure(response.statusText ?? 'Failed to change password');
    }
  }

  Future<ResponseModel> deleteUser() async {
    Response response = await apiClient.deleteData(AppConstants.customerRemoveUri, handleError: false);
    if (response.statusCode == 200) {
      return ResponseModel(true, 'your_account_remove_successfully'.tr);
    } else {
      throw ServerFailure(response.statusText ?? 'Failed to delete user');
    }
  }
}
