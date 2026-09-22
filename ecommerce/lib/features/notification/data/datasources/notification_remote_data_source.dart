import 'package:get/get_connect/connect.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/util/app_constants.dart';

class NotificationRemoteDataSource {
  final ApiClient _apiClient;
  const NotificationRemoteDataSource(this._apiClient);

  Future<Response> getNotifications() =>
      _apiClient.getData(AppConstants.notificationUri);
}
