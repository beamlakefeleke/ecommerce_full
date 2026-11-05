import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce/util/app_constants.dart';

abstract class CheckoutLocalDataSource {
  String getSharedPrefDmTipIndex();
  Future<bool> saveSharedPrefDmTipIndex(String index);
}

class CheckoutLocalDataSourceImpl implements CheckoutLocalDataSource {
  final SharedPreferences sharedPreferences;

  CheckoutLocalDataSourceImpl({required this.sharedPreferences});

  @override
  String getSharedPrefDmTipIndex() =>
      sharedPreferences.getString(AppConstants.dmTipIndex) ?? '';

  @override
  Future<bool> saveSharedPrefDmTipIndex(String index) =>
      sharedPreferences.setString(AppConstants.dmTipIndex, index);
}
