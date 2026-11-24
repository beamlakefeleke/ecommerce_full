import 'package:get/get_utils/get_utils.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/common/models/config_model.dart';
import 'package:ecommerce/common/models/module_model.dart';
import 'package:ecommerce/common/models/response_model.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/splash/data/datasources/splash_local_data_source.dart';
import 'package:ecommerce/features/splash/data/datasources/splash_remote_data_source.dart';
import 'package:ecommerce/features/splash/domain/models/landing_model.dart';
import 'package:ecommerce/features/splash/domain/repositories/splash_repository.dart';
import 'package:ecommerce/util/app_constants.dart';

class SplashRepositoryImpl implements SplashRepository {
  final SplashRemoteDataSource remoteDataSource;
  final SplashLocalDataSource localDataSource;
  final ApiClient apiClient;

  SplashRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.apiClient,
  });

  @override
  Future<Either<Failure, SplashConfigResult>> getConfigData() async {
    try {
      final body = await remoteDataSource.getConfigData();
      final config = ConfigModel.fromJson(body);
      return Right(SplashConfigResult(configModel: config, rawData: body));
    } on NetworkException catch (_) {
      return Left(NetworkFailure(ApiClient.noInternetMessage));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<LandingModel?> getLandingPageData() =>
      remoteDataSource.getLandingPageData();

  @override
  Future<Either<Failure, List<ModuleModel>>> getModules({
    Map<String, String>? headers,
  }) async {
    try {
      final list = await remoteDataSource.getModules(headers: headers);
      return Right(list);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<ResponseModel> subscribeEmail(String email) async {
    try {
      final body = await _subscribeEmailRemote(email);
      return body;
    } catch (_) {
      return ResponseModel(false, 'subscription_failed'.tr);
    }
  }

  Future<ResponseModel> _subscribeEmailRemote(String email) async {
    // Reuse apiClient directly for the subscription endpoint.
    final response = await apiClient.postData(
      AppConstants.subscriptionUri,
      {'email': email},
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ResponseModel(true, 'subscribed_successfully'.tr);
    }
    return ResponseModel(false, response.statusText);
  }

  // ---- Local delegates ----

  @override
  Future<ModuleModel?> initSharedData() => localDataSource.initSharedData();

  @override
  void disableIntro() => localDataSource.disableIntro();

  @override
  bool? showIntro() => localDataSource.showIntro();

  @override
  Future<void> setModule(ModuleModel? module) =>
      localDataSource.setModule(module);

  @override
  Future<void> setCacheModule(ModuleModel? module) =>
      localDataSource.setCacheModule(module);

  @override
  ModuleModel? getCacheModule() => localDataSource.getCacheModule();

  @override
  ModuleModel? getModule() => localDataSource.getModule();

  @override
  bool getSavedCookiesData() => localDataSource.getSavedCookiesData();

  @override
  Future<void> saveCookiesData(bool data) =>
      localDataSource.saveCookiesData(data);

  @override
  void cookiesStatusChange(String? data) =>
      localDataSource.cookiesStatusChange(data);

  @override
  bool getAcceptCookiesStatus(String data) =>
      localDataSource.getAcceptCookiesStatus(data);

  @override
  bool getSuggestedLocationStatus() =>
      localDataSource.getSuggestedLocationStatus();

  @override
  Future<void> saveSuggestedLocationStatus(bool data) =>
      localDataSource.saveSuggestedLocationStatus(data);
}
