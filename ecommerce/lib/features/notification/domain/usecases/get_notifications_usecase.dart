import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/notification/domain/entities/app_notification.dart';
import 'package:ecommerce/features/notification/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase
    implements UseCase<List<AppNotification>, NoParams> {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AppNotification>>> call(NoParams params) {
    return repository.getNotifications();
  }
}
