import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce/util/app_constants.dart';

class NotificationLocalDataSource {
  final SharedPreferences _prefs;
  const NotificationLocalDataSource(this._prefs);

  void saveSeenCount(int count) =>
      _prefs.setInt(AppConstants.notificationCount, count);

  int? getSeenCount() => _prefs.getInt(AppConstants.notificationCount);
}
