import 'package:get/get_connect/connect.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/notification/data/models/notification_model.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Raw API access for the notification feature. Throws [ServerException] /
/// [NetworkException]; the repository converts these to [Failure]s. No GetX
/// `Response` type leaks above this layer.
abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final Response response = await apiClient.getData(
      AppConstants.notificationUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<NotificationModel> list = [];
      response.body.forEach(
        (notification) => list.add(NotificationModel.fromJson(notification)),
      );
      return list;
    }
    throw _exceptionFor(response);
  }

  Exception _exceptionFor(Response response) {
    // statusCode 0/1 are the ApiClient's "no internet" sentinels.
    if (response.statusCode == null ||
        response.statusCode == 0 ||
        response.statusCode == 1) {
      return NetworkException(response.statusText ?? 'No internet connection');
    }
    return ServerException(response.statusText ?? 'Server error');
  }
}
