import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/notification/data/datasources/notification_local_data_source.dart';
import 'package:ecommerce/features/notification/data/datasources/notification_remote_data_source.dart';
import 'package:ecommerce/features/notification/domain/models/notification_model.dart';
import 'package:ecommerce/features/notification/domain/repositories/notification_repository_new.dart';

class NotificationRepositoryImpl implements NotificationRepositoryNew {
  final NotificationRemoteDataSource _remote;
  final NotificationLocalDataSource _local;

  const NotificationRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<Failure, List<NotificationModel>>> getNotifications() async {
    try {
      final response = await _remote.getNotifications();
      if (response.statusCode == 200) {
        final list = <NotificationModel>[];
        for (final item in response.body as List) {
          list.add(NotificationModel.fromJson(item));
        }
        return Right(list);
      }
      return Left(
        ServerFailure(
          response.statusText ?? 'Failed to load notifications',
          statusCode: response.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  void saveSeenCount(int count) => _local.saveSeenCount(count);

  @override
  int? getSeenCount() => _local.getSeenCount();
}
