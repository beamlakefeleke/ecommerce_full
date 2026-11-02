import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/features/chat/domain/entities/conversation.dart';
import 'package:ecommerce/features/chat/domain/repositories/chat_repository.dart';
import 'package:ecommerce/features/chat/domain/usecases/get_conversation_list_usecase.dart';
import 'package:ecommerce/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:ecommerce/features/chat/domain/usecases/search_conversation_usecase.dart';
import 'package:ecommerce/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:ecommerce/features/chat/enums/user_type_enum.dart';
import 'package:ecommerce/features/chat/presentation/bloc/chat_event.dart';
import 'package:ecommerce/features/chat/presentation/bloc/chat_state.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/helper/date_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetConversationListUseCase getConversationList;
  final SearchConversationUseCase searchConversation;
  final GetMessagesUseCase getMessages;
  final SendMessageUseCase sendMessage;
  final ChatRepository repository;

  ChatBloc({
    required this.getConversationList,
    required this.searchConversation,
    required this.getMessages,
    required this.sendMessage,
    required this.repository,
  }) : super(const ChatState()) {
    on<ConversationListRequested>(_onConversationList);
    on<ConversationSearchRequested>(_onSearch);
    on<ConversationSearchCleared>(_onSearchCleared);
    on<MessagesRequested>(_onMessages);
    on<ChatMessageSent>(_onSend);
    on<ChatImagePicked>(_onImagePick);
    on<ChatImageRemoved>(_onImageRemove);
    on<ChatImagesCleared>(_onImagesClear);
    on<ChatSendButtonToggled>(_onSendToggle);
    on<ChatTypeChanged>(_onTypeChanged);
    on<ChatTabToggled>(_onTabToggle);
    on<ChatNotificationBodySet>(_onNotificationBodySet);
    on<ChatSelectedIndexSet>(_onSelectedIndex);
    on<ChatConversationReloadedWithNotification>(_onConversationReload);
    on<ChatMessageReloadedWithNotification>(_onMessageReload);
  }

  Future<void> _onConversationList(
    ConversationListRequested event,
    Emitter<ChatState> emit,
  ) async {
    if (event.offset == 1) {
      emit(state.copyWith(hasAdmin: true, clearSearch: true));
    }
    final result = await getConversationList(
      GetConversationListParams(offset: event.offset, type: event.type),
    );
    result.fold((f) => emit(state.copyWith(errorMessage: f.message)), (list) {
      ConversationList merged;
      if (event.offset == 1) {
        merged = list;
      } else {
        merged = ConversationList(
          totalSize: list.totalSize,
          offset: list.offset,
          conversations: [
            ...(state.conversationList?.conversations ?? []),
            ...list.conversations,
          ],
        );
      }
      final resolved = _injectAdminConversation(merged);
      emit(
        state.copyWith(conversationList: resolved.$1, hasAdmin: resolved.$2),
      );
    });
  }

  Future<void> _onSearch(
    ConversationSearchRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(searchConversationList: const ConversationList()));
    final result = await searchConversation(event.name);
    result.fold((f) => emit(state.copyWith(errorMessage: f.message)), (list) {
      final resolved = _injectAdminConversation(list);
      emit(state.copyWith(searchConversationList: resolved.$1));
    });
  }

  void _onSearchCleared(
    ConversationSearchCleared event,
    Emitter<ChatState> emit,
  ) => emit(state.copyWith(clearSearch: true));

  Future<void> _onMessages(
    MessagesRequested event,
    Emitter<ChatState> emit,
  ) async {
    if (event.firstLoad) {
      emit(
        state.copyWith(
          clearMessage: true,
          isSendButtonActive: false,
          isLoading: false,
        ),
      );
    }
    final notif = event.notificationBody;
    final String userType = notif == null || notif.adminId != null
        ? UserType.admin.name
        : notif.restaurantId != null
        ? UserType.vendor.name
        : UserType.delivery_man.name;
    final int? userId =
        notif?.restaurantId ??
        notif?.deliverymanId ??
        (notif?.adminId != null ? 0 : null);

    final result = await getMessages(
      GetMessagesParams(
        offset: event.offset,
        userId: userId,
        userType: userType,
        conversationId: event.conversationId,
      ),
    );
    result.fold((f) => emit(state.copyWith(errorMessage: f.message)), (
      chatMsgs,
    ) {
      ChatMessages resolved;
      if (event.offset == 1) {
        // mark conversation as read
        if (event.conversationId != null &&
            state.conversationList != null &&
            !ResponsiveHelper.isDesktop(Get.context)) {
          final int idx = state.conversationList!.conversations.indexWhere(
            (c) => c.id == event.conversationId,
          );
          if (idx != -1) {
            final updatedConvs = List<ChatConversation>.from(
              state.conversationList!.conversations,
            );
            updatedConvs[idx] = updatedConvs[idx].copyWith(
              unreadMessageCount: 0,
            );
            emit(
              state.copyWith(
                conversationList: ConversationList(
                  totalSize: state.conversationList!.totalSize,
                  offset: state.conversationList!.offset,
                  conversations: updatedConvs,
                ),
              ),
            );
          }
        }
        resolved = _sortMessages(chatMsgs, notif?.adminId);
      } else {
        resolved = chatMsgs.copyWith(
          totalSize: chatMsgs.totalSize,
          offset: chatMsgs.offset,
          messages: [
            ...(state.messageModel?.messages ?? []),
            ...chatMsgs.messages,
          ],
        );
      }
      emit(state.copyWith(messageModel: resolved));
    });
  }

  Future<void> _onSend(ChatMessageSent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(isLoading: true));
    final notif = event.notificationBody;
    final String userType = notif == null || notif.adminId != null
        ? UserType.admin.name
        : notif.restaurantId != null
        ? UserType.vendor.name
        : UserType.delivery_man.name;
    final int? userId =
        notif?.restaurantId ??
        notif?.deliverymanId ??
        (notif?.adminId != null ? 0 : null);

    final result = await sendMessage(
      SendMessageParams(
        message: event.message,
        images: state.chatImages,
        userId: userId,
        userType: userType,
        conversationId: event.conversationId,
        index: event.index,
      ),
    );
    result.fold(
      (f) => emit(state.copyWith(isLoading: false, errorMessage: f.message)),
      (chatMsgs) {
        final resolved = _sortMessages(chatMsgs, notif?.adminId);
        final String lastMsgTime = resolved.messages.isNotEmpty
            ? DateConverter.isoStringToLocalString(
                resolved.messages.first.createdAt!,
              )
            : '';

        // update last message time in conversation list
        ConversationList? updatedList = state.conversationList;
        if (event.index != null && updatedList != null) {
          final convs = List<ChatConversation>.from(updatedList.conversations);
          if (event.index! < convs.length) {
            convs[event.index!] = convs[event.index!].copyWith(
              lastMessageTime: lastMsgTime,
            );
          }
          updatedList = ConversationList(
            totalSize: updatedList.totalSize,
            offset: updatedList.offset,
            conversations: convs,
          );
        }

        emit(
          state.copyWith(
            chatImages: const [],
            chatRawImages: const [],
            isSendButtonActive: false,
            isLoading: false,
            messageModel: resolved,
            conversationList: updatedList,
          ),
        );
        // refresh messages after 2s (mirrors legacy behaviour)
        Future.delayed(const Duration(seconds: 2), () {
          add(
            MessagesRequested(
              offset: 1,
              notificationBody: notif,
              conversationId: event.conversationId,
            ),
          );
        });
      },
    );
  }

  Future<void> _onImagePick(
    ChatImagePicked event,
    Emitter<ChatState> emit,
  ) async {
    final List<XFile> picked = await ImagePicker().pickMultiImage(
      imageQuality: 40,
    );
    final List<XFile> current = List.from(state.chatImages);
    final List<Uint8List> currentRaw = List.from(state.chatRawImages);
    for (final XFile xFile in picked) {
      if (current.length >= 3) {
        showCustomSnackBar('can_not_add_more_than_3_image'.tr);
        break;
      }
      final XFile compressed = await repository.compressImage(xFile);
      current.add(compressed);
      currentRaw.add(await compressed.readAsBytes());
    }
    emit(
      state.copyWith(
        chatImages: current,
        chatRawImages: currentRaw,
        isSendButtonActive: current.isNotEmpty,
      ),
    );
  }

  void _onImageRemove(ChatImageRemoved event, Emitter<ChatState> emit) {
    final List<XFile> imgs = List.from(state.chatImages)..removeAt(event.index);
    final List<Uint8List> raws = List.from(state.chatRawImages)
      ..removeAt(event.index);
    emit(
      state.copyWith(
        chatImages: imgs,
        chatRawImages: raws,
        isSendButtonActive: imgs.isNotEmpty || event.messageText.isNotEmpty,
      ),
    );
  }

  void _onImagesClear(ChatImagesCleared event, Emitter<ChatState> emit) =>
      emit(state.copyWith(chatImages: const [], chatRawImages: const []));

  void _onSendToggle(ChatSendButtonToggled event, Emitter<ChatState> emit) =>
      emit(state.copyWith(isSendButtonActive: !state.isSendButtonActive));

  void _onTypeChanged(ChatTypeChanged event, Emitter<ChatState> emit) =>
      emit(state.copyWith(type: event.type));

  void _onTabToggle(ChatTabToggled event, Emitter<ChatState> emit) =>
      emit(state.copyWith(clickTab: !state.clickTab));

  void _onNotificationBodySet(
    ChatNotificationBodySet event,
    Emitter<ChatState> emit,
  ) => emit(state.copyWith(notificationBody: event.body));

  void _onSelectedIndex(ChatSelectedIndexSet event, Emitter<ChatState> emit) =>
      emit(state.copyWith(selectedIndex: event.index));

  void _onConversationReload(
    ChatConversationReloadedWithNotification event,
    Emitter<ChatState> emit,
  ) {
    final convs = List<ChatConversation>.from(
      state.conversationList?.conversations ?? [],
    );
    final int idx = convs.indexWhere((c) => c.id == event.conversationId);
    if (idx == -1) return;
    final ChatConversation c = convs.removeAt(idx);
    convs.insert(
      0,
      c.copyWith(unreadMessageCount: (c.unreadMessageCount ?? 0) + 1),
    );
    emit(
      state.copyWith(
        conversationList: ConversationList(
          totalSize: state.conversationList!.totalSize,
          offset: state.conversationList!.offset,
          conversations: convs,
        ),
      ),
    );
  }

  void _onMessageReload(
    ChatMessageReloadedWithNotification event,
    Emitter<ChatState> emit,
  ) {
    if (state.messageModel == null) return;
    emit(
      state.copyWith(
        messageModel: state.messageModel!.copyWith(
          messages: [event.message, ...state.messageModel!.messages],
        ),
      ),
    );
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  /// Inject admin business info into the conversation list (mirrors old controller).
  /// Returns (resolved list, hasAdmin flag).
  (ConversationList, bool) _injectAdminConversation(ConversationList list) {
    bool hasAdmin = false;
    if (list.conversations.isEmpty) return (list, hasAdmin);
    final int idx = list.conversations.indexWhere(
      (c) =>
          c.receiverType == UserType.admin.name ||
          c.senderType == UserType.admin.name,
    );
    if (idx == -1 || ResponsiveHelper.isDesktop(Get.context)) {
      return (list, hasAdmin);
    }
    hasAdmin = true;
    final splash = Get.find<SplashController>().configModel;
    final ChatUser adminUser = ChatUser(
      id: 0,
      fName: splash?.businessName,
      lName: '',
      phone: splash?.phone,
      email: splash?.email,
      image: splash?.logo,
    );
    final convs = List<ChatConversation>.from(list.conversations);
    final bool isSender = convs[idx].receiverType == UserType.admin.name
        ? false
        : true;
    convs[idx] = isSender
        ? convs[idx].copyWith(sender: adminUser)
        : convs[idx].copyWith(receiver: adminUser);
    return (
      ConversationList(
        totalSize: list.totalSize,
        offset: list.offset,
        conversations: convs,
      ),
      hasAdmin,
    );
  }

  ChatMessages _sortMessages(ChatMessages msgs, int? adminId) {
    if (msgs.conversation == null) return msgs;
    ChatConversation conv = msgs.conversation!;

    // Swap sender/receiver if receiver is the user
    if (conv.receiverType == UserType.user.name ||
        conv.receiverType == UserType.customer.name) {
      conv = conv.copyWith(sender: conv.receiver, receiver: conv.sender);
    }

    // Override receiver with admin info when needed
    if (adminId != null) {
      final splash = Get.find<SplashController>().configModel;
      conv = conv.copyWith(
        receiver: ChatUser(
          id: 0,
          fName: splash?.businessName,
          lName: '',
          image: splash?.logo,
        ),
      );
    }

    return msgs.copyWith(conversation: conv);
  }
}
