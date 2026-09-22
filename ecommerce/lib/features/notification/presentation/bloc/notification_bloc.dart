import 'package:ecommerce/helper/date_converter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/notification/domain/repositories/notification_repository_new.dart';
import 'package:ecommerce/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:ecommerce/features/notification/presentation/bloc/notification_event.dart';
import 'package:ecommerce/features/notification/presentation/bloc/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase _getNotifications;
  final NotificationRepositoryNew _repository;

  NotificationBloc({
    required GetNotificationsUseCase getNotificationsUseCase,
    required NotificationRepositoryNew repository,
  }) : _getNotifications = getNotificationsUseCase,
       _repository = repository,
       super(const NotificationState()) {
    on<NotificationListFetched>(_onFetched);
    on<NotificationSeenCountSaved>(_onSeenCountSaved);
    on<NotificationCleared>(_onCleared);
  }

  Future<void> _onFetched(
    NotificationListFetched event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.loading));

    final result = await _getNotifications();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NotificationStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (list) {
        // Sort descending by updatedAt — matches legacy controller behaviour
        list.sort(
          (a, b) => DateConverter.isoStringToLocalDate(
            b.updatedAt ?? '',
          ).compareTo(DateConverter.isoStringToLocalDate(a.updatedAt ?? '')),
        );
        final hasUnread = list.length != (_repository.getSeenCount() ?? 0);
        emit(
          state.copyWith(
            status: NotificationStatus.success,
            notifications: list,
            hasUnread: hasUnread,
          ),
        );
      },
    );
  }

  void _onSeenCountSaved(
    NotificationSeenCountSaved event,
    Emitter<NotificationState> emit,
  ) {
    _repository.saveSeenCount(event.count);
    emit(state.copyWith(hasUnread: false));
  }

  void _onCleared(NotificationCleared event, Emitter<NotificationState> emit) {
    emit(state.copyWith(notifications: null));
  }
}
