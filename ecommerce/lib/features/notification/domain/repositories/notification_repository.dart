import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/notification/domain/entities/app_notification.dart';

/// Abstract contract for the notification feature. Implemented in the data
/// layer. Network calls return `Either<Failure, T>`; the seen-count helpers
/// are synchronous local (SharedPreferences) state.
abstract class NotificationRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications();

  void saveSeenNotificationCount(int count);

  int? getSeenNotificationCount();
}
