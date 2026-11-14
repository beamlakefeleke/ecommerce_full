import 'package:ecommerce/features/notification/domain/entities/app_notification.dart';

/// Data-layer model: the single serializable representation of a notification.
/// Owns `fromJson`/`toJson`/`toEntity` (rule 2) and maps the wire shape into
/// the pure [AppNotification] entity.
class NotificationModel {
  final int? id;
  final NotificationDataModel? data;
  final String? createdAt;
  final String? updatedAt;

  const NotificationModel({this.id, this.data, this.createdAt, this.updatedAt});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      data: json['data'] != null
          ? NotificationDataModel.fromJson(json['data'])
          : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (data != null) 'data': data!.toJson(),
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  AppNotification toEntity() => AppNotification(
    id: id,
    data: data?.toEntity(),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

class NotificationDataModel {
  final String? title;
  final String? description;
  final String? image;
  final String? type;

  const NotificationDataModel({
    this.title,
    this.description,
    this.image,
    this.type,
  });

  factory NotificationDataModel.fromJson(Map<String, dynamic> json) {
    return NotificationDataModel(
      title: json['title'],
      description: json['description']?.toString(),
      image: json['image'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'image': image,
    'type': type,
  };

  NotificationData toEntity() => NotificationData(
    title: title,
    description: description,
    image: image,
    type: type,
  );
}
