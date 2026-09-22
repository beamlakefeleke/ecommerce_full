import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';

/// Manages the "Remember me" saved credentials (phone, password, country code).
class ManageSavedCredentialsUseCase {
  final AuthRepository _repository;

  const ManageSavedCredentialsUseCase(this._repository);

  Future<void> save({
    required String number,
    required String password,
    required String countryCode,
  }) {
    return _repository.saveUserNumberAndPassword(number, password, countryCode);
  }

  String getNumber() => _repository.getUserNumber();

  String getCountryCode() => _repository.getUserCountryCode();

  String getPassword() => _repository.getUserPassword();

  Future<bool> clear() => _repository.clearUserNumberAndPassword();
}
