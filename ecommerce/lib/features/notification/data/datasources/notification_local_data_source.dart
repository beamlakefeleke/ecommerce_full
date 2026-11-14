import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Local (SharedPreferences) storage for the "seen notification count" used to
/// drive the unread badge.
abstract class NotificationLocalDataSource {
  void saveSeenNotificationCount(int count);

  int? getSeenNotificationCount();
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final SharedPreferences sharedPreferences;

  NotificationLocalDataSourceImpl({required this.sharedPreferences});

  @override
  void saveSeenNotificationCount(int count) {
    sharedPreferences.setInt(AppConstants.notificationCount, count);
  }

  @override
  int? getSeenNotificationCount() {
    return sharedPreferences.getInt(AppConstants.notificationCount);
  }
}
