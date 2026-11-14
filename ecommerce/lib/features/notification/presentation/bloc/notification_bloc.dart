import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/notification/domain/entities/app_notification.dart';
import 'package:ecommerce/features/notification/domain/repositories/notification_repository.dart';
import 'package:ecommerce/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:ecommerce/helper/date_converter.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotifications;
  final NotificationRepository repository;

  NotificationBloc({required this.getNotifications, required this.repository})
    : super(const NotificationState()) {
    on<NotificationListRequested>(_onListRequested);
    on<NotificationCleared>(_onCleared);
    on<NotificationMarkedSeen>(_onMarkedSeen);
  }

  Future<void> _onListRequested(
    NotificationListRequested event,
    Emitter<NotificationState> emit,
  ) async {
    // Only fetch if not yet loaded, unless an explicit reload is requested
    // (mirrors the legacy `_notificationList == null || reload` guard).
    if (state.notifications != null && !event.reload) {
      return;
    }

    emit(state.copyWith(status: NotificationStatus.loading));
    final result = await getNotifications(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (notifications) {
        final sorted = List<AppNotification>.from(notifications)
          ..sort(
            (a, b) => DateConverter.isoStringToLocalDate(
              a.updatedAt!,
            ).compareTo(DateConverter.isoStringToLocalDate(b.updatedAt!)),
          );
        // Newest first.
        final ordered = sorted.reversed.toList();
        final seenCount = repository.getSeenNotificationCount();
        emit(
          state.copyWith(
            status: NotificationStatus.loaded,
            notifications: ordered,
            hasNotification: ordered.length != seenCount,
          ),
        );
      },
    );
  }

  void _onCleared(NotificationCleared event, Emitter<NotificationState> emit) {
    emit(
      state.copyWith(
        clearNotifications: true,
        status: NotificationStatus.initial,
      ),
    );
  }

  void _onMarkedSeen(
    NotificationMarkedSeen event,
    Emitter<NotificationState> emit,
  ) {
    repository.saveSeenNotificationCount(event.count);
    emit(state.copyWith(hasNotification: false));
  }
}
