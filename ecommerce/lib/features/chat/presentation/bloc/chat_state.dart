import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/features/chat/domain/entities/conversation.dart';
import 'package:ecommerce/features/notification/domain/models/notification_body_model.dart';

class ChatState extends Equatable {
  final ConversationList? conversationList;
  final ConversationList? searchConversationList;
  final ChatMessages? messageModel;

  // image picker state
  final List<XFile> chatImages;
  final List<Uint8List> chatRawImages;

  // UI flags
  final bool isSendButtonActive;
  final bool isLoading;
  final bool hasAdmin;
  final String type;
  final bool clickTab;
  final int? selectedIndex;
  final NotificationBodyModel? notificationBody;

  final String? errorMessage;

  const ChatState({
    this.conversationList,
    this.searchConversationList,
    this.messageModel,
    this.chatImages = const [],
    this.chatRawImages = const [],
    this.isSendButtonActive = false,
    this.isLoading = false,
    this.hasAdmin = true,
    this.type = 'vendor',
    this.clickTab = false,
    this.selectedIndex,
    this.notificationBody,
    this.errorMessage,
  });

  ChatState copyWith({
    ConversationList? conversationList,
    ConversationList? searchConversationList,
    ChatMessages? messageModel,
    List<XFile>? chatImages,
    List<Uint8List>? chatRawImages,
    bool? isSendButtonActive,
    bool? isLoading,
    bool? hasAdmin,
    String? type,
    bool? clickTab,
    int? selectedIndex,
    NotificationBodyModel? notificationBody,
    String? errorMessage,
    bool clearSearch = false,
    bool clearMessage = false,
  }) {
    return ChatState(
      conversationList: conversationList ?? this.conversationList,
      searchConversationList: clearSearch
          ? null
          : (searchConversationList ?? this.searchConversationList),
      messageModel: clearMessage ? null : (messageModel ?? this.messageModel),
      chatImages: chatImages ?? this.chatImages,
      chatRawImages: chatRawImages ?? this.chatRawImages,
      isSendButtonActive: isSendButtonActive ?? this.isSendButtonActive,
      isLoading: isLoading ?? this.isLoading,
      hasAdmin: hasAdmin ?? this.hasAdmin,
      type: type ?? this.type,
      clickTab: clickTab ?? this.clickTab,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      notificationBody: notificationBody ?? this.notificationBody,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    conversationList,
    searchConversationList,
    messageModel,
    chatImages,
    chatRawImages,
    isSendButtonActive,
    isLoading,
    hasAdmin,
    type,
    clickTab,
    selectedIndex,
    notificationBody,
    errorMessage,
  ];
}
