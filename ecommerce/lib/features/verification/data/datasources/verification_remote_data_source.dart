import 'package:get/get_connect/connect.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/util/app_constants.dart';

abstract class VerificationRemoteDataSource {
  Future<String> forgetPassword(String? phone);
  Future<String> resetPassword({
    String? resetToken,
    String? number,
    String? password,
    String? confirmPassword,
  });
  Future<String> verifyPhone(String? phone, String otp);
  Future<String> verifyToken(String? phone, String token);
}

class VerificationRemoteDataSourceImpl
    implements VerificationRemoteDataSource {
  final ApiClient apiClient;

  VerificationRemoteDataSourceImpl({required this.apiClient});

  Exception _exceptionFor(Response response) {
    if (response.statusCode == null ||
        response.statusCode == 0 ||
        response.statusCode == 1) {
      return NetworkException(response.statusText ?? 'No internet connection');
    }
    return ServerException(
      response.body['message']?.toString() ??
          response.statusText ??
          'Server error',
    );
  }

  @override
  Future<String> forgetPassword(String? phone) async {
    final Response response = await apiClient.postData(
      AppConstants.forgetPasswordUri,
      {'phone': phone},
      handleError: false,
    );
    if (response.statusCode == 200) {
      return response.body['message']?.toString() ?? '';
    }
    throw _exceptionFor(response);
  }

  @override
  Future<String> resetPassword({
    String? resetToken,
    String? number,
    String? password,
    String? confirmPassword,
  }) async {
    final Response response = await apiClient.postData(
      AppConstants.resetPasswordUri,
      {
        '_method': 'put',
        'reset_token': resetToken,
        'phone': number,
        'password': password,
        'confirm_password': confirmPassword,
      },
      handleError: false,
    );
    if (response.statusCode == 200) {
      return response.body['message']?.toString() ?? '';
    }
    throw _exceptionFor(response);
  }

  @override
  Future<String> verifyPhone(String? phone, String otp) async {
    final Response response = await apiClient.postData(
      AppConstants.verifyPhoneUri,
      {'phone': phone, 'otp': otp},
      handleError: false,
    );
    if (response.statusCode == 200) {
      return response.body['message']?.toString() ?? '';
    }
    throw _exceptionFor(response);
  }

  @override
  Future<String> verifyToken(String? phone, String token) async {
    final Response response = await apiClient.postData(
      AppConstants.verifyTokenUri,
      {'phone': phone, 'reset_token': token},
      handleError: false,
    );
    if (response.statusCode == 200) {
      return response.body['message']?.toString() ?? '';
    }
    throw _exceptionFor(response);
  }
}
