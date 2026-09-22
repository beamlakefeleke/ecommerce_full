sealed class NotificationEvent {
  const NotificationEvent();
}

class NotificationListFetched extends NotificationEvent {
  const NotificationListFetched();
}

class NotificationSeenCountSaved extends NotificationEvent {
  final int count;
  const NotificationSeenCountSaved(this.count);
}

class NotificationCleared extends NotificationEvent {
  const NotificationCleared();
}
