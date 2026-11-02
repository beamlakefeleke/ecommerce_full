import 'package:ecommerce/features/chat/data/models/chat_model.dart';
import 'package:ecommerce/features/chat/domain/entities/conversation.dart';

class ConversationsModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<Conversation?>? conversations;

  ConversationsModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.conversations,
  });

  ConversationsModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['conversations'] != null) {
      conversations = <Conversation?>[];
      json['conversations'].forEach(
        (v) => conversations!.add(Conversation.fromJson(v)),
      );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (conversations != null) {
      data['conversations'] = conversations!.map((v) => v!.toJson()).toList();
    }
    return data;
  }

  ConversationList toEntity() => ConversationList(
    totalSize: totalSize,
    limit: limit,
    offset: offset,
    conversations:
        conversations
            ?.whereType<Conversation>()
            .map((c) => c.toEntity())
            .toList() ??
        const [],
  );
}

class Conversation {
  int? id;
  int? senderId;
  String? senderType;
  int? receiverId;
  String? receiverType;
  int? unreadMessageCount;
  int? lastMessageId;
  String? lastMessageTime;
  String? createdAt;
  String? updatedAt;
  User? sender;
  User? receiver;
  Message? lastMessage;

  Conversation({
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

  Conversation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderId = json['sender_id'];
    senderType = json['sender_type'];
    receiverId = json['receiver_id'];
    receiverType = json['receiver_type'];
    unreadMessageCount = json['unread_message_count'];
    lastMessageId = json['last_message_id'];
    lastMessageTime = json['last_message_time'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    sender = json['sender'] != null ? User.fromJson(json['sender']) : null;
    receiver = json['receiver'] != null
        ? User.fromJson(json['receiver'])
        : null;
    lastMessage = json['last_message'] != null
        ? Message.fromJson(json['last_message'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['sender_id'] = senderId;
    data['sender_type'] = senderType;
    data['receiver_id'] = receiverId;
    data['receiver_type'] = receiverType;
    data['unread_message_count'] = unreadMessageCount;
    data['last_message_id'] = lastMessageId;
    data['last_message_time'] = lastMessageTime;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (sender != null) data['sender'] = sender!.toJson();
    if (receiver != null) data['receiver'] = receiver!.toJson();
    if (lastMessage != null) data['last_message'] = lastMessage!.toJson();
    return data;
  }

  ChatConversation toEntity() => ChatConversation(
    id: id,
    senderId: senderId,
    senderType: senderType,
    receiverId: receiverId,
    receiverType: receiverType,
    unreadMessageCount: unreadMessageCount,
    lastMessageId: lastMessageId,
    lastMessageTime: lastMessageTime,
    createdAt: createdAt,
    updatedAt: updatedAt,
    sender: sender?.toEntity(),
    receiver: receiver?.toEntity(),
    lastMessage: lastMessage?.toEntity(),
  );
}

class User {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? image;
  String? createdAt;
  String? updatedAt;

  User({
    this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'f_name': fName,
    'l_name': lName,
    'phone': phone,
    'email': email,
    'image': image,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  ChatUser toEntity() => ChatUser(
    id: id,
    fName: fName,
    lName: lName,
    phone: phone,
    email: email,
    image: image,
  );
}
