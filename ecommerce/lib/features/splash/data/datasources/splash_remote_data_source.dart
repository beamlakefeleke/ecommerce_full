import 'package:get/get_connect/connect.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/common/models/module_model.dart';
import 'package:ecommerce/features/splash/domain/models/landing_model.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Raw API access for the splash feature. Throws [ServerException] /
/// [NetworkException]; the repository converts these to [Failure]s.
abstract class SplashRemoteDataSource {
  /// Returns the raw response body map; parsed into [ConfigModel] in the
  /// repository so the data model import stays inside data/.
  Future<Map<String, dynamic>> getConfigData();
  Future<LandingModel?> getLandingPageData();
  Future<List<ModuleModel>> getModules({Map<String, String>? headers});
}

class SplashRemoteDataSourceImpl implements SplashRemoteDataSource {
  final ApiClient apiClient;
  SplashRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getConfigData() async {
    final Response response = await apiClient.getData(
      AppConstants.configUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return response.body as Map<String, dynamic>;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<LandingModel?> getLandingPageData() async {
    final Response response = await apiClient.getData(
      AppConstants.landingPageUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return LandingModel.fromJson(response.body);
    }
    // Landing data is optional — return null on error rather than throwing.
    return null;
  }

  @override
  Future<List<ModuleModel>> getModules({
    Map<String, String>? headers,
  }) async {
    final Response response = await apiClient.getData(
      AppConstants.moduleUri,
      headers: headers,
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<ModuleModel> list = [];
      (response.body as List).forEach(
        (m) => list.add(ModuleModel.fromJson(m)),
      );
      return list;
    }
    throw _exceptionFor(response);
  }

  Exception _exceptionFor(Response response) {
    if (response.statusCode == null ||
        response.statusCode == 0 ||
        response.statusCode == 1) {
      return NetworkException(response.statusText ?? 'No internet connection');
    }
    return ServerException(response.statusText ?? 'Server error');
  }
}
