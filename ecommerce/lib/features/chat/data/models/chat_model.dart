import 'dart:convert';
import 'package:ecommerce/features/chat/data/models/conversation_model.dart';
import 'package:ecommerce/features/chat/domain/entities/conversation.dart';

class ChatModel {
  int? totalSize;
  int? limit;
  int? offset;
  bool? status;
  Conversation? conversation;
  List<Message>? messages;

  ChatModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.status,
    this.conversation,
    this.messages,
  });

  ChatModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    status = json['status'];
    conversation = json['conversation'] != null
        ? Conversation.fromJson(json['conversation'])
        : null;
    if (json['messages'] != null) {
      messages = <Message>[];
      json['messages'].forEach((v) => messages!.add(Message.fromJson(v)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    data['status'] = status;
    if (conversation != null) data['conversation'] = conversation!.toJson();
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  ChatMessages toEntity() => ChatMessages(
    totalSize: totalSize,
    limit: limit,
    offset: offset,
    status: status,
    conversation: conversation?.toEntity(),
    messages: messages?.map((m) => m.toEntity()).toList() ?? const [],
  );
}

class Message {
  int? id;
  int? conversationId;
  int? senderId;
  String? message;
  List<String>? files;
  int? isSeen;
  String? createdAt;
  String? updatedAt;

  Message({
    this.id,
    this.conversationId,
    this.senderId,
    this.message,
    this.files,
    this.isSeen,
    this.createdAt,
    this.updatedAt,
  });

  Message.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversationId = json['conversation_id'];
    senderId = json['sender_id'];
    message = json['message'];
    files = (json['file'] != 'null' && json['file'] != null)
        ? jsonDecode(json['file']).cast<String>()
        : [];
    isSeen = json['is_seen'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversation_id': conversationId,
    'sender_id': senderId,
    'message': message,
    'file': files,
    'is_seen': isSeen,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  ChatMessage toEntity() => ChatMessage(
    id: id,
    conversationId: conversationId,
    senderId: senderId,
    message: message,
    files: files,
    isSeen: isSeen,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
