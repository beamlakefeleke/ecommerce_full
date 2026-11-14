part of 'notification_bloc.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Load the notification list. When [reload] is false the list is only fetched
/// if it has not been loaded yet (mirrors the legacy `reload` guard).
class NotificationListRequested extends NotificationEvent {
  final bool reload;

  const NotificationListRequested({this.reload = false});

  @override
  List<Object?> get props => [reload];
}

/// Clears the loaded list (used when (re)entering the notification screen).
class NotificationCleared extends NotificationEvent {
  const NotificationCleared();
}

/// Persists that [count] notifications have been seen and clears the unread
/// badge. Dispatched by the notification screen once the list is shown.
class NotificationMarkedSeen extends NotificationEvent {
  final int count;

  const NotificationMarkedSeen(this.count);

  @override
  List<Object?> get props => [count];
}
