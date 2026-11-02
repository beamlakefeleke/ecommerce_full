import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:ecommerce/features/chat/presentation/bloc/chat_event.dart';
import 'package:ecommerce/features/chat/presentation/bloc/chat_state.dart';
import 'package:ecommerce/features/chat/enums/user_type_enum.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/profile/controllers/profile_controller.dart';
import 'package:ecommerce/features/notification/domain/models/notification_body_model.dart';
import 'package:ecommerce/features/chat/domain/entities/conversation.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/not_logged_in_screen.dart';
import 'package:ecommerce/common/widgets/paginated_list_view.dart';
import 'package:ecommerce/common/widgets/web_search_field.dart';
import 'package:ecommerce/features/chat/widgets/chatting_shimmer.dart';
import 'package:ecommerce/features/chat/widgets/message_bubble_widget.dart';
import 'package:ecommerce/features/chat/presentation/widgets/web_conversation_list_view_widget.dart';
import 'package:get/get.dart';

class WebChatViewWidget extends StatefulWidget {
  final ScrollController scrollController;
  final TextEditingController searchController;

  const WebChatViewWidget({
    super.key,
    required this.scrollController,
    required this.searchController,
  });

  @override
  State<WebChatViewWidget> createState() => _WebChatViewWidgetState();
}

class _WebChatViewWidgetState extends State<WebChatViewWidget>
    with TickerProviderStateMixin {
  final TextEditingController _inputMessageController = TextEditingController();
  final ScrollController _scrollControllerChat = ScrollController();
  final ScrollController _scrollController1 = ScrollController();
  late TabController _tabController;
  ChatUser? _selectedUser;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputMessageController.dispose();
    _scrollControllerChat.dispose();
    _scrollController1.dispose();
    super.dispose();
  }

  String _userType(NotificationBodyModel? notif) {
    if (notif?.adminId != null) return UserType.admin.name;
    if (notif?.deliverymanId != null) return UserType.delivery_man.name;
    return UserType.vendor.name;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return Column(
          children: [
            Container(
              height: 64,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
              child: Center(child: Text('live_chat'.tr, style: robotoMedium)),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                physics: const BouncingScrollPhysics(),
                child: AuthHelper.isLoggedIn()
                    ? FooterView(
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: Row(
                            children: [
                              // ── Conversation list pane ──
                              Container(
                                width: 415,
                                height: 570,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeLarge,
                                  vertical: Dimensions.paddingSizeSmall,
                                ),
                                decoration: ShapeDecoration(
                                  color: Theme.of(context).cardColor,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color!
                                          .withValues(alpha: 0.04),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault,
                                    ),
                                  ),
                                  shadows: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color!
                                          .withValues(alpha: 0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'messages'.tr,
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeDefault,
                                    ),

                                    // Search
                                    if (AuthHelper.isLoggedIn() &&
                                        state.conversationList != null &&
                                        state
                                            .conversationList!
                                            .conversations
                                            .isNotEmpty)
                                      Center(
                                        child: WebSearchField(
                                          prefixWidget:
                                              state.searchConversationList !=
                                                  null
                                              ? null
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: Dimensions
                                                            .paddingSizeDefault,
                                                        left: Dimensions
                                                            .paddingSizeSmall,
                                                      ),
                                                  child: Image.asset(
                                                    Images.searchIcon,
                                                    height: 18,
                                                    width: 18,
                                                  ),
                                                ),
                                          controller: widget.searchController,
                                          hint: 'search_'.tr,
                                          suffixIcon:
                                              state.searchConversationList !=
                                                  null
                                              ? Icons.close
                                              : null,
                                          onSubmit: (text) {
                                            if (text.trim().isNotEmpty) {
                                              context.read<ChatBloc>().add(
                                                ConversationSearchRequested(
                                                  text.trim(),
                                                ),
                                              );
                                            } else {
                                              showCustomSnackBar(
                                                'write_something'.tr,
                                              );
                                            }
                                          },
                                          iconPressed: () {
                                            if (state.searchConversationList !=
                                                null) {
                                              widget.searchController.clear();
                                              context.read<ChatBloc>().add(
                                                const ConversationSearchCleared(),
                                              );
                                            } else if (widget
                                                .searchController
                                                .text
                                                .trim()
                                                .isNotEmpty) {
                                              context.read<ChatBloc>().add(
                                                ConversationSearchRequested(
                                                  widget.searchController.text
                                                      .trim(),
                                                ),
                                              );
                                            } else {
                                              showCustomSnackBar(
                                                'write_something'.tr,
                                              );
                                            }
                                          },
                                        ),
                                      ),

                                    Expanded(
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Column(
                                          children: [
                                            // Admin entry
                                            InkWell(
                                              onTap: () {
                                                final notif =
                                                    NotificationBodyModel(
                                                      type: 'admin',
                                                      notificationType:
                                                          NotificationType
                                                              .message,
                                                      adminId: 0,
                                                      restaurantId: null,
                                                      deliverymanId: null,
                                                    );
                                                context.read<ChatBloc>().add(
                                                  MessagesRequested(
                                                    offset: 1,
                                                    notificationBody: notif,
                                                    user: _selectedUser,
                                                    conversationId: 0,
                                                    firstLoad: true,
                                                  ),
                                                );
                                                context.read<ChatBloc>().add(
                                                  ChatNotificationBodySet(
                                                    NotificationBodyModel(
                                                      type: 'admin',
                                                      notificationType:
                                                          NotificationType
                                                              .message,
                                                      adminId: 0,
                                                      restaurantId: null,
                                                      deliverymanId: null,
                                                      conversationId: 0,
                                                      image:
                                                          '${Get.find<SplashController>().configModel!.baseUrls!.businessLogoUrl}/${Get.find<SplashController>().configModel!.logo}',
                                                      name:
                                                          '${Get.find<SplashController>().configModel!.businessName}',
                                                      receiverType: 'admin',
                                                    ),
                                                  ),
                                                );
                                                context.read<ChatBloc>().add(
                                                  const ChatSelectedIndexSet(
                                                    -1,
                                                  ),
                                                );
                                                Get.find<ProfileController>()
                                                    .getUserInfo();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        Dimensions
                                                            .radiusDefault,
                                                      ),
                                                  color:
                                                      state.selectedIndex == -1
                                                      ? Theme.of(context)
                                                            .primaryColor
                                                            .withValues(
                                                              alpha: 0.10,
                                                            )
                                                      : Theme.of(
                                                          context,
                                                        ).cardColor,
                                                ),
                                                margin: const EdgeInsets.only(
                                                  top: Dimensions
                                                      .paddingSizeSmall,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    Dimensions.paddingSizeSmall,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      ClipOval(
                                                        child: CustomImage(
                                                          height: 50,
                                                          width: 50,
                                                          image:
                                                              '${Get.find<SplashController>().configModel!.baseUrls!.businessLogoUrl}/${Get.find<SplashController>().configModel!.logo}',
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeSmall,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          '${Get.find<SplashController>().configModel!.businessName}',
                                                          style: robotoMedium,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              color: Theme.of(context)
                                                  .disabledColor
                                                  .withValues(alpha: 0.5),
                                            ),

                                            // TabBar
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: TabBar(
                                                controller: _tabController,
                                                isScrollable: true,
                                                indicatorColor: Theme.of(
                                                  context,
                                                ).primaryColor,
                                                labelColor: Theme.of(
                                                  context,
                                                ).primaryColor,
                                                unselectedLabelColor: Theme.of(
                                                  context,
                                                ).disabledColor,
                                                indicatorSize:
                                                    TabBarIndicatorSize.label,
                                                labelStyle: robotoBold.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeDefault,
                                                ),
                                                unselectedLabelStyle:
                                                    robotoRegular.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeDefault,
                                                    ),
                                                tabs: [
                                                  Tab(text: 'store'.tr),
                                                  Tab(text: 'delivery_man'.tr),
                                                ],
                                                onTap: (index) {
                                                  context.read<ChatBloc>().add(
                                                    ChatTypeChanged(
                                                      index == 0
                                                          ? 'vendor'
                                                          : 'delivery_man',
                                                    ),
                                                  );
                                                  context.read<ChatBloc>().add(
                                                    const ChatTabToggled(),
                                                  );
                                                },
                                              ),
                                            ),

                                            // TabBarView
                                            SizedBox(
                                              height:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.5,
                                              child: TabBarView(
                                                controller: _tabController,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                children: [
                                                  WebConversationListViewWidget(
                                                    scrollController:
                                                        _scrollController1,
                                                    type: 'vendor',
                                                    onUserSelected: (u) =>
                                                        setState(
                                                          () =>
                                                              _selectedUser = u,
                                                        ),
                                                  ),
                                                  WebConversationListViewWidget(
                                                    scrollController:
                                                        _scrollController1,
                                                    type: 'delivery_man',
                                                    onUserSelected: (u) =>
                                                        setState(
                                                          () =>
                                                              _selectedUser = u,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                width: Dimensions.paddingSizeLarge,
                              ),

                              // ── Chat pane ──
                              Expanded(
                                child: Container(
                                  height: 569,
                                  padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeDefault,
                                  ),
                                  decoration: ShapeDecoration(
                                    color: Theme.of(context).cardColor,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withValues(alpha: 0.04),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault,
                                      ),
                                    ),
                                    shadows: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withValues(alpha: 0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // header
                                      if (state.notificationBody != null)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeDefault,
                                            vertical:
                                                Dimensions.paddingSizeSmall,
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  ClipOval(
                                                    child: CustomImage(
                                                      height: 50,
                                                      width: 50,
                                                      image: state
                                                          .notificationBody!
                                                          .image!,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeSmall,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                state
                                                                    .notificationBody!
                                                                    .name!,
                                                                style:
                                                                    robotoMedium,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            Text(
                                                              '(${state.notificationBody!.receiverType!.tr})',
                                                              style: robotoRegular.copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSizeExtraSmall,
                                                                color: Theme.of(
                                                                  context,
                                                                ).disabledColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: Dimensions
                                                              .paddingSizeExtraSmall,
                                                        ),
                                                        Text(
                                                          state
                                                              .notificationBody!
                                                              .receiverType!
                                                              .tr,
                                                          style: robotoRegular
                                                              .copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSizeSmall,
                                                                color: Theme.of(
                                                                  context,
                                                                ).disabledColor,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeExtraSmall,
                                              ),
                                              Divider(
                                                color: Theme.of(context)
                                                    .disabledColor
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ],
                                          ),
                                        ),

                                      // messages
                                      Expanded(
                                        child: state.notificationBody != null
                                            ? state.messageModel != null
                                                  ? state
                                                            .messageModel!
                                                            .messages
                                                            .isNotEmpty
                                                        ? SingleChildScrollView(
                                                            controller:
                                                                _scrollControllerChat,
                                                            reverse: true,
                                                            child: PaginatedListView(
                                                              scrollController:
                                                                  _scrollControllerChat,
                                                              reverse: true,
                                                              totalSize: state
                                                                  .messageModel
                                                                  ?.totalSize,
                                                              offset: state
                                                                  .messageModel
                                                                  ?.offset,
                                                              onPaginate: (offset) {
                                                                final notif = state
                                                                    .notificationBody;
                                                                context.read<ChatBloc>().add(
                                                                  MessagesRequested(
                                                                    offset:
                                                                        offset!,
                                                                    notificationBody:
                                                                        notif,
                                                                    user:
                                                                        _selectedUser,
                                                                    conversationId:
                                                                        notif
                                                                            ?.conversationId,
                                                                  ),
                                                                );
                                                              },
                                                              itemView: ListView.builder(
                                                                physics:
                                                                    const NeverScrollableScrollPhysics(),
                                                                shrinkWrap:
                                                                    true,
                                                                reverse: true,
                                                                itemCount: state
                                                                    .messageModel!
                                                                    .messages
                                                                    .length,
                                                                itemBuilder: (_, idx) => MessageBubbleWidget(
                                                                  message: state
                                                                      .messageModel!
                                                                      .messages[idx],
                                                                  user: state
                                                                      .messageModel!
                                                                      .conversation!
                                                                      .receiver,
                                                                  userType:
                                                                      _userType(
                                                                        state
                                                                            .notificationBody,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : Center(
                                                            child: Text(
                                                              'no_message_found'
                                                                  .tr,
                                                            ),
                                                          )
                                                  : const ChattingShimmer()
                                            : Center(
                                                child: Text(
                                                  'no_conversation_selected'.tr,
                                                ),
                                              ),
                                      ),

                                      // input
                                      if (state.notificationBody != null)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius:
                                                const BorderRadius.all(
                                                  Radius.circular(
                                                    Dimensions.radiusDefault,
                                                  ),
                                                ),
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.2),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: Dimensions
                                                                .paddingSizeDefault,
                                                          ),
                                                      child: Column(
                                                        children: [
                                                          TextField(
                                                            inputFormatters: [
                                                              LengthLimitingTextInputFormatter(
                                                                Dimensions
                                                                    .messageInputLength,
                                                              ),
                                                            ],
                                                            controller:
                                                                _inputMessageController,
                                                            textCapitalization:
                                                                TextCapitalization
                                                                    .sentences,
                                                            style:
                                                                robotoRegular,
                                                            keyboardType:
                                                                TextInputType
                                                                    .multiline,
                                                            maxLines: null,
                                                            decoration: InputDecoration(
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              hintText:
                                                                  'start_a_new_message'
                                                                      .tr,
                                                              hintStyle: robotoRegular.copyWith(
                                                                color: Theme.of(
                                                                  context,
                                                                ).hintColor,
                                                                fontSize: Dimensions
                                                                    .fontSizeSmall,
                                                              ),
                                                            ),
                                                            onChanged: (text) {
                                                              final active = text
                                                                  .trim()
                                                                  .isNotEmpty;
                                                              if (active !=
                                                                  state
                                                                      .isSendButtonActive) {
                                                                context
                                                                    .read<
                                                                      ChatBloc
                                                                    >()
                                                                    .add(
                                                                      const ChatSendButtonToggled(),
                                                                    );
                                                              }
                                                            },
                                                          ),
                                                          if (state
                                                              .chatImages
                                                              .isNotEmpty)
                                                            SizedBox(
                                                              height: 100,
                                                              child: ListView.builder(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                itemCount: state
                                                                    .chatImages
                                                                    .length,
                                                                itemBuilder: (_, idx) => Padding(
                                                                  padding:
                                                                      const EdgeInsets.only(
                                                                        top: 8,
                                                                        right:
                                                                            8,
                                                                        bottom:
                                                                            8,
                                                                      ),
                                                                  child: Stack(
                                                                    children: [
                                                                      ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              20,
                                                                            ),
                                                                        child: Image.memory(
                                                                          state
                                                                              .chatRawImages[idx],
                                                                          width:
                                                                              100,
                                                                          height:
                                                                              100,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                      Positioned(
                                                                        top: 0,
                                                                        right:
                                                                            0,
                                                                        child: InkWell(
                                                                          onTap: () => context
                                                                              .read<
                                                                                ChatBloc
                                                                              >()
                                                                              .add(
                                                                                ChatImageRemoved(
                                                                                  idx,
                                                                                  _inputMessageController.text.trim(),
                                                                                ),
                                                                              ),
                                                                          child: Container(
                                                                            color:
                                                                                Colors.white,
                                                                            child: const Icon(
                                                                              Icons.clear,
                                                                              color: Colors.red,
                                                                              size: 16,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () => context
                                                        .read<ChatBloc>()
                                                        .add(
                                                          const ChatImagePicked(),
                                                        ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(
                                                        Dimensions
                                                            .paddingSizeDefault,
                                                      ),
                                                      child: Image.asset(
                                                        Images.image,
                                                        width: 25,
                                                        height: 25,
                                                        color: Theme.of(
                                                          context,
                                                        ).hintColor,
                                                      ),
                                                    ),
                                                  ),
                                                  state.isLoading
                                                      ? const Padding(
                                                          padding: EdgeInsets.all(
                                                            Dimensions
                                                                .paddingSizeDefault,
                                                          ),
                                                          child: SizedBox(
                                                            height: 25,
                                                            width: 25,
                                                            child:
                                                                CircularProgressIndicator(),
                                                          ),
                                                        )
                                                      : InkWell(
                                                          onTap: () {
                                                            if (state
                                                                .isSendButtonActive) {
                                                              context.read<ChatBloc>().add(
                                                                ChatMessageSent(
                                                                  message:
                                                                      _inputMessageController
                                                                          .text,
                                                                  notificationBody:
                                                                      state
                                                                          .notificationBody,
                                                                  conversationId: state
                                                                      .notificationBody
                                                                      ?.conversationId,
                                                                ),
                                                              );
                                                              _inputMessageController
                                                                  .clear();
                                                            } else {
                                                              showCustomSnackBar(
                                                                'write_something'
                                                                    .tr,
                                                              );
                                                            }
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  Dimensions
                                                                      .paddingSizeDefault,
                                                                ),
                                                            child: Image.asset(
                                                              Images.send,
                                                              width: 25,
                                                              height: 25,
                                                              color:
                                                                  state
                                                                      .isSendButtonActive
                                                                  ? Theme.of(
                                                                      context,
                                                                    ).primaryColor
                                                                  : Theme.of(
                                                                      context,
                                                                    ).hintColor,
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : NotLoggedInScreen(callBack: (_) {}),
              ),
            ),
          ],
        );
      },
    );
  }
}
