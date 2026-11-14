import 'package:equatable/equatable.dart';

/// Pure business entity for a single customer notification.
///
/// No JSON, no Flutter, no data-layer imports (rule 1). The data layer's
/// [NotificationModel] maps the wire JSON into this entity.
class AppNotification extends Equatable {
  final int? id;
  final NotificationData? data;
  final String? createdAt;
  final String? updatedAt;

  const AppNotification({this.id, this.data, this.createdAt, this.updatedAt});

  @override
  List<Object?> get props => [id, data, createdAt, updatedAt];
}

/// The payload carried by a notification (title/description/image/type).
class NotificationData extends Equatable {
  final String? title;
  final String? description;
  final String? image;
  final String? type;

  const NotificationData({this.title, this.description, this.image, this.type});

  @override
  List<Object?> get props => [title, description, image, type];
}
