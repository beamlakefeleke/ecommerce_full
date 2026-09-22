import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/notification/domain/models/notification_model.dart';

abstract class NotificationRepositoryNew {
  Future<Either<Failure, List<NotificationModel>>> getNotifications();
  void saveSeenCount(int count);
  int? getSeenCount();
}
