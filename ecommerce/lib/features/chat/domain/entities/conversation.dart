import 'package:equatable/equatable.dart';

/// Pure domain entities for the chat feature.
/// `User` from the chat domain is different from profile User —
/// it represents a chat participant (sender/receiver).
class ChatUser extends Equatable {
  final int? id;
  final String? fName;
  final String? lName;
  final String? phone;
  final String? email;
  final String? image;

  const ChatUser({
    this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.image,
  });

  String get fullName => '${fName ?? ''} ${lName ?? ''}'.trim();

  @override
  List<Object?> get props => [id, fName, lName, phone, email, image];
}

class ChatMessage extends Equatable {
  final int? id;
  final int? conversationId;
  final int? senderId;
  final String? message;
  final List<String>? files;
  final int? isSeen;
  final String? createdAt;
  final String? updatedAt;

  const ChatMessage({
    this.id,
    this.conversationId,
    this.senderId,
    this.message,
    this.files,
    this.isSeen,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, conversationId, senderId, message, createdAt];
}

class ChatConversation extends Equatable {
  final int? id;
  final int? senderId;
  final String? senderType;
  final int? receiverId;
  final String? receiverType;
  final int? unreadMessageCount;
  final int? lastMessageId;
  final String? lastMessageTime;
  final String? createdAt;
  final String? updatedAt;
  final ChatUser? sender;
  final ChatUser? receiver;
  final ChatMessage? lastMessage;

  const ChatConversation({
    this.id,
    this.senderId,
    this.senderType,
    this.receiverId,
    this.receiverType,
    this.unreadMessageCount,
    this.lastMessageId,
    this.lastMessageTime,
    this.createdAt,
    this.updatedAt,
    this.sender,
    this.receiver,
    this.lastMessage,
  });

  ChatConversation copyWith({
    ChatUser? sender,
    ChatUser? receiver,
    int? unreadMessageCount,
    String? lastMessageTime,
  }) => ChatConversation(
    id: id,
    senderId: senderId,
    senderType: senderType,
    receiverId: receiverId,
    receiverType: receiverType,
    unreadMessageCount: unreadMessageCount ?? this.unreadMessageCount,
    lastMessageId: lastMessageId,
    lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    createdAt: createdAt,
    updatedAt: updatedAt,
    sender: sender ?? this.sender,
    receiver: receiver ?? this.receiver,
    lastMessage: lastMessage,
  );

  @override
  List<Object?> get props => [id, senderType, receiverType, unreadMessageCount];
}

class ChatMessages extends Equatable {
  final int? totalSize;
  final int? limit;
  final int? offset;
  final bool? status;
  final ChatConversation? conversation;
  final List<ChatMessage> messages;

  const ChatMessages({
    this.totalSize,
    this.limit,
    this.offset,
    this.status,
    this.conversation,
    this.messages = const [],
  });

  ChatMessages copyWith({
    int? totalSize,
    int? offset,
    List<ChatMessage>? messages,
    ChatConversation? conversation,
  }) => ChatMessages(
    totalSize: totalSize ?? this.totalSize,
    limit: limit,
    offset: offset ?? this.offset,
    status: status,
    conversation: conversation ?? this.conversation,
    messages: messages ?? this.messages,
  );

  @override
  List<Object?> get props => [totalSize, offset, messages, conversation];
}

class ConversationList extends Equatable {
  final int? totalSize;
  final int? limit;
  final int? offset;
  final List<ChatConversation> conversations;

  const ConversationList({
    this.totalSize,
    this.limit,
    this.offset,
    this.conversations = const [],
  });

  @override
  List<Object?> get props => [totalSize, offset, conversations];
}
