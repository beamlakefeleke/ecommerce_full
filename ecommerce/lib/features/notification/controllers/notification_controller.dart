import 'package:get/get.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/notification/domain/models/notification_model.dart';
import 'package:ecommerce/features/notification/domain/service/notification_service_interface.dart';
import 'package:ecommerce/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:ecommerce/features/notification/presentation/bloc/notification_event.dart';
import 'package:ecommerce/features/notification/presentation/bloc/notification_state.dart';

/// Thin GetX adapter — delegates to [NotificationBloc].
class NotificationController extends GetxController implements GetxService {
  // ignore: unused_field
  final NotificationServiceInterface notificationServiceInterface;
  NotificationController({required this.notificationServiceInterface});

  NotificationBloc get _bloc => getIt<NotificationBloc>();
  NotificationState get _state => _bloc.state;

  List<NotificationModel>? get notificationList => _state.notifications;
  bool get hasNotification => _state.hasUnread;

  Future<int> getNotificationList(bool reload) async {
    if (_state.notifications == null || reload) {
      _bloc.add(const NotificationListFetched());
      await Future.delayed(Duration.zero);
      update();
    }
    return _state.notifications?.length ?? 0;
  }

  void saveSeenNotificationCount(int count) {
    _bloc.add(NotificationSeenCountSaved(count));
    update();
  }

  int? getSeenNotificationCount() => _state.notifications?.length;

  void clearNotification() {
    _bloc.add(const NotificationCleared());
  }
}
