import 'package:ecommerce/common/models/response_model.dart';
import 'package:ecommerce/features/auth/domain/entities/social_login_body.dart' as auth_domain;
import 'package:ecommerce/features/auth/domain/models/social_log_in_body.dart' as legacy_model;
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin GetX adapter to maintain compatibility with non-migrated consumers
/// that still rely on `Get.find<AuthController>()`.
///
/// This delegates all core auth calls to the new [AuthRepository] from the Clean Architecture migration,
/// and handles legacy loose fields (like DM tips and earning points) via SharedPreferences directly
/// until they are fully relocated to their respective new features.
class AuthController extends GetxController implements GetxService {
  final AuthRepository _authRepository;
  final SharedPreferences _sharedPreferences;

  AuthController({
    required AuthRepository authRepository,
    required SharedPreferences sharedPreferences,
  })  : _authRepository = authRepository,
        _sharedPreferences = sharedPreferences;

  bool get isLoading => false;

  bool get notification => _authRepository.isNotificationActive();

  void setNotificationActive(bool isActive) {
    _authRepository.setNotificationActive(isActive);
    update();
  }

  bool isGuestLoggedIn() {
    return _authRepository.isGuestLoggedIn();
  }

  String getGuestId() {
    return _authRepository.getGuestId();
  }

  bool isLoggedIn() {
    return _authRepository.isLoggedIn();
  }

  Future<bool> clearSharedAddress() async {
    return await _authRepository.clearSharedAddress();
  }

  Future<ResponseModel> guestLogin() async {
    final result = await _authRepository.guestLogin();
    return result.fold(
      (failure) => ResponseModel(false, failure.message),
      (guestId) => ResponseModel(true, guestId),
    );
  }

  void updateToken() {
    _authRepository.updateToken();
  }

  String getGuestNumber() {
    return _authRepository.getGuestContactNumber();
  }

  Future<void> saveGuestNumber(String number) async {
    await _authRepository.saveGuestContactNumber(number);
  }

  Future<ResponseModel> login(String phone, String password) async {
    final result = await _authRepository.login(phone: phone, password: password);
    return result.fold(
      (failure) => ResponseModel(false, failure.message),
      (response) => ResponseModel(true, response.token),
    );
  }

  Future<ResponseModel> registerWithSocialMedia(legacy_model.SocialLogInBody legacyBody) async {
    final newBody = auth_domain.SocialLoginBody(
      email: legacyBody.email,
      token: legacyBody.token,
      uniqueId: legacyBody.uniqueId,
      medium: legacyBody.medium,
      phone: legacyBody.phone,
    );
    final result = await _authRepository.registerWithSocialMedia(newBody);
    return result.fold(
      (failure) => ResponseModel(false, failure.message),
      (response) => ResponseModel(true, response.token),
    );
  }

  Future<ResponseModel> loginWithSocialMedia(legacy_model.SocialLogInBody legacyBody) async {
    final newBody = auth_domain.SocialLoginBody(
      email: legacyBody.email,
      token: legacyBody.token,
      uniqueId: legacyBody.uniqueId,
      medium: legacyBody.medium,
      phone: legacyBody.phone,
    );
    final result = await _authRepository.loginWithSocialMedia(newBody);
    return result.fold(
      (failure) => ResponseModel(false, failure.message),
      (response) => ResponseModel(true, response.token),
    );
  }

  String getUserCountryCode() {
    return _authRepository.getUserCountryCode();
  }

  String getUserNumber() {
    return _authRepository.getUserNumber();
  }

  String getUserPassword() {
    return _authRepository.getUserPassword();
  }

  String getUserToken() {
    return _authRepository.getUserToken();
  }

  bool clearSharedData() {
    return _authRepository.clearSharedData();
  }

  void socialLogout() {
    // Only delegates clearSharedData in the new architecture
    clearSharedData();
  }

  void updateZone() {
    _authRepository.updateZone();
  }

  // --- Loose properties not in Auth domain ---

  String getDmTipIndex() {
    return _sharedPreferences.getString(AppConstants.dmTipIndex) ?? '';
  }

  void saveDmTipIndex(String tip) {
    _sharedPreferences.setString(AppConstants.dmTipIndex, tip);
  }

  String getEarningPint() {
    return _sharedPreferences.getString(AppConstants.earnPoint) ?? '';
  }

  void saveEarningPoint(String point) {
    _sharedPreferences.setString(AppConstants.earnPoint, point);
  }
}
