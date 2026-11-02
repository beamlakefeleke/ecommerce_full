import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/chat/domain/entities/conversation.dart';
import 'package:ecommerce/features/notification/domain/models/notification_body_model.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class ConversationListRequested extends ChatEvent {
  final int offset;
  final String type;
  const ConversationListRequested({this.offset = 1, this.type = ''});
  @override
  List<Object?> get props => [offset, type];
}

class ConversationSearchRequested extends ChatEvent {
  final String name;
  const ConversationSearchRequested(this.name);
  @override
  List<Object?> get props => [name];
}

class ConversationSearchCleared extends ChatEvent {
  const ConversationSearchCleared();
}

class MessagesRequested extends ChatEvent {
  final int offset;
  final NotificationBodyModel? notificationBody;
  final ChatUser? user;
  final int? conversationId;
  final bool firstLoad;
  const MessagesRequested({
    required this.offset,
    this.notificationBody,
    this.user,
    this.conversationId,
    this.firstLoad = false,
  });
  @override
  List<Object?> get props => [
    offset,
    notificationBody,
    conversationId,
    firstLoad,
  ];
}

class ChatMessageSent extends ChatEvent {
  final String message;
  final NotificationBodyModel? notificationBody;
  final int? conversationId;
  final int? index;
  const ChatMessageSent({
    required this.message,
    this.notificationBody,
    this.conversationId,
    this.index,
  });
  @override
  List<Object?> get props => [message, notificationBody, conversationId];
}

class ChatImagePicked extends ChatEvent {
  const ChatImagePicked();
}

class ChatImageRemoved extends ChatEvent {
  final int index;
  final String messageText;
  const ChatImageRemoved(this.index, this.messageText);
  @override
  List<Object?> get props => [index, messageText];
}

class ChatImagesCleared extends ChatEvent {
  const ChatImagesCleared();
}

class ChatSendButtonToggled extends ChatEvent {
  const ChatSendButtonToggled();
}

class ChatTypeChanged extends ChatEvent {
  final String type;
  const ChatTypeChanged(this.type);
  @override
  List<Object?> get props => [type];
}

class ChatTabToggled extends ChatEvent {
  const ChatTabToggled();
}

class ChatNotificationBodySet extends ChatEvent {
  final NotificationBodyModel body;
  const ChatNotificationBodySet(this.body);
  @override
  List<Object?> get props => [body];
}

class ChatSelectedIndexSet extends ChatEvent {
  final int index;
  const ChatSelectedIndexSet(this.index);
  @override
  List<Object?> get props => [index];
}

class ChatConversationReloadedWithNotification extends ChatEvent {
  final int conversationId;
  const ChatConversationReloadedWithNotification(this.conversationId);
  @override
  List<Object?> get props => [conversationId];
}

class ChatMessageReloadedWithNotification extends ChatEvent {
  final ChatMessage message;
  const ChatMessageReloadedWithNotification(this.message);
  @override
  List<Object?> get props => [message];
}
