import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/notification/data/datasources/notification_local_data_source.dart';
import 'package:ecommerce/features/notification/data/datasources/notification_remote_data_source.dart';
import 'package:ecommerce/features/notification/domain/entities/app_notification.dart';
import 'package:ecommerce/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NotificationLocalDataSource localDataSource;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications() async {
    try {
      final models = await remoteDataSource.getNotifications();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  void saveSeenNotificationCount(int count) {
    localDataSource.saveSeenNotificationCount(count);
  }

  @override
  int? getSeenNotificationCount() {
    return localDataSource.getSeenNotificationCount();
  }
}
