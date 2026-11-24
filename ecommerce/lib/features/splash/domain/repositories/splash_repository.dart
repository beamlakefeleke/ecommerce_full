import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/common/models/config_model.dart';
import 'package:ecommerce/common/models/module_model.dart';
import 'package:ecommerce/common/models/response_model.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/splash/domain/models/landing_model.dart';

/// Abstract contract for the splash feature. Returns `Either<Failure, T>`;
/// raw exceptions never cross this boundary. Local (synchronous) operations
/// are exposed directly (no failure path needed for SharedPrefs reads).
abstract class SplashRepository {
  /// Returns the parsed [ConfigModel] plus the raw data map (needed for
  /// `moduleConfig` lookups) on success.
  Future<Either<Failure, SplashConfigResult>> getConfigData();
  Future<LandingModel?> getLandingPageData();
  Future<Either<Failure, List<ModuleModel>>> getModules({
    Map<String, String>? headers,
  });
  Future<ResponseModel> subscribeEmail(String email);

  // Local — synchronous or simple async, no failure path.
  Future<ModuleModel?> initSharedData();
  void disableIntro();
  bool? showIntro();
  Future<void> setModule(ModuleModel? module);
  Future<void> setCacheModule(ModuleModel? module);
  ModuleModel? getCacheModule();
  ModuleModel? getModule();
  bool getSavedCookiesData();
  Future<void> saveCookiesData(bool data);
  void cookiesStatusChange(String? data);
  bool getAcceptCookiesStatus(String data);
  bool getSuggestedLocationStatus();
  Future<void> saveSuggestedLocationStatus(bool data);
}

/// Carries both the parsed config and the raw body map so the bloc can resolve
/// module-config entries (e.g. `_data['module_config'][moduleType]`).
class SplashConfigResult {
  final ConfigModel configModel;
  final Map<String, dynamic> rawData;

  const SplashConfigResult({required this.configModel, required this.rawData});
}
