part of 'notification_bloc.dart';

enum NotificationStatus { initial, loading, loaded, error }

/// Single immutable state. A status enum is used (not a sealed hierarchy)
/// because the loaded list + the `hasNotification` badge flag are read across
/// several screens (home, parcel/taxi app bars) and must survive reloads.
class NotificationState extends Equatable {
  final NotificationStatus status;

  /// `null` until the first successful load (drives the loading spinner).
  final List<AppNotification>? notifications;

  /// True when there are more notifications than the user has seen.
  final bool hasNotification;

  final String? errorMessage;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications,
    this.hasNotification = false,
    this.errorMessage,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    List<AppNotification>? notifications,
    bool clearNotifications = false,
    bool? hasNotification,
    String? errorMessage,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: clearNotifications
          ? null
          : (notifications ?? this.notifications),
      hasNotification: hasNotification ?? this.hasNotification,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    notifications,
    hasNotification,
    errorMessage,
  ];
}
