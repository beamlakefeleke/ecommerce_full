import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Handles checkout-related SharedPreferences operations.
class CheckoutLocalDataSource {
  final SharedPreferences _prefs;

  const CheckoutLocalDataSource(this._prefs);

  Future<bool> saveDmTipIndex(String index) =>
      _prefs.setString(AppConstants.dmTipIndex, index);

  String getDmTipIndex() => _prefs.getString(AppConstants.dmTipIndex) ?? '';
}
