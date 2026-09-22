import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/notification/domain/models/notification_model.dart';

enum NotificationStatus { initial, loading, success, failure }

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<NotificationModel>? notifications;
  final bool hasUnread;
  final String? errorMessage;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications,
    this.hasUnread = false,
    this.errorMessage,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationModel>? notifications,
    bool? hasUnread,
    String? errorMessage,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      hasUnread: hasUnread ?? this.hasUnread,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notifications, hasUnread, errorMessage];
}
