import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/notification/domain/models/notification_model.dart';
import 'package:ecommerce/features/notification/domain/repositories/notification_repository_new.dart';

class GetNotificationsUseCase {
  final NotificationRepositoryNew _repository;
  const GetNotificationsUseCase(this._repository);

  Future<Either<Failure, List<NotificationModel>>> call() =>
      _repository.getNotifications();
}
