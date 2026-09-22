import 'package:get/get_connect/connect.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Handles all auth-related API calls.
///
/// Returns raw [Response] objects — the repository converts these
/// into typed results or Failures.
class AuthRemoteDataSource {
  final ApiClient _apiClient;

  const AuthRemoteDataSource(this._apiClient);

  Future<Response> login({
    required String phone,
    required String password,
    String? guestId,
  }) async {
    final Map<String, String> data = {
      'phone': phone,
      'password': password,
    };
    if (guestId != null && guestId.isNotEmpty) {
      data['guest_id'] = guestId;
    }
    return _apiClient.postData(
      AppConstants.loginUri,
      data,
      handleError: false,
    );
  }

  Future<Response> register(Map<String, dynamic> body) async {
    return _apiClient.postData(
      AppConstants.registerUri,
      body,
      handleError: false,
    );
  }

  Future<Response> guestLogin(String? fcmToken) async {
    return _apiClient.postData(
      AppConstants.guestLoginUri,
      {'fcm_token': fcmToken},
    );
  }

  Future<Response> loginWithSocialMedia(
    Map<String, dynamic> body, {
    int timeout = 60,
  }) async {
    return _apiClient.postData(
      AppConstants.socialLoginUri,
      body,
      timeout: timeout,
    );
  }

  Future<Response> registerWithSocialMedia(Map<String, dynamic> body) async {
    return _apiClient.postData(AppConstants.socialRegisterUri, body);
  }

  Future<Response> updateToken(String token) async {
    return _apiClient.postData(
      AppConstants.tokenUri,
      {'_method': 'put', 'cm_firebase_token': token},
      handleError: false,
    );
  }

  Future<Response> updateZone() async {
    return _apiClient.getData(AppConstants.updateZoneUri);
  }
}
