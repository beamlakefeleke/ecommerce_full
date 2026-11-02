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
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/common/widgets/not_logged_in_screen.dart';
import 'package:ecommerce/common/widgets/paginated_list_view.dart';
import 'package:ecommerce/common/widgets/web_menu_bar.dart';
import 'package:ecommerce/features/chat/widgets/message_bubble_widget.dart';
import 'package:get/get.dart';

class ChatScreen extends StatefulWidget {
  final NotificationBodyModel? notificationBody;
  final ChatUser? user;
  final int? conversationID;
  final int? index;
  final bool fromNotification;
  const ChatScreen({
    super.key,
    required this.notificationBody,
    required this.user,
    this.conversationID,
    this.index,
    this.fromNotification = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputMessageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (AuthHelper.isLoggedIn()) {
      context.read<ChatBloc>().add(
        MessagesRequested(
          offset: 1,
          notificationBody: widget.notificationBody,
          user: widget.user,
          conversationId: widget.conversationID,
          firstLoad: true,
        ),
      );
      if (Get.find<ProfileController>().userInfoModel == null ||
          Get.find<ProfileController>().userInfoModel!.userInfo == null) {
        Get.find<ProfileController>().getUserInfo();
      }
    }
  }

  String _baseUrl(NotificationBodyModel? notif) {
    if (notif?.adminId != null) {
      return Get.find<SplashController>()
              .configModel!
              .baseUrls!
              .businessLogoUrl ??
          '';
    } else if (notif?.deliverymanId != null) {
      return Get.find<SplashController>()
              .configModel!
              .baseUrls!
              .deliveryManImageUrl ??
          '';
    }
    return Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl ??
        '';
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
        final bool isLoggedIn = AuthHelper.isLoggedIn();

        return PopScope(
          canPop: !widget.fromNotification,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && widget.fromNotification) {
              Get.offAllNamed(RouteHelper.getInitialRoute());
            }
          },
          child: Scaffold(
            endDrawer: const MenuDrawer(),
            endDrawerEnableOpenDragGesture: false,
            appBar: ResponsiveHelper.isDesktop(context)
                ? const WebMenuBar()
                : AppBar(
                    leading: IconButton(
                      onPressed: () {
                        if (widget.fromNotification) {
                          Get.offAllNamed(RouteHelper.getInitialRoute());
                        } else {
                          Get.back();
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                    title: Text(
                      state.messageModel?.conversation != null
                          ? state
                                    .messageModel!
                                    .conversation!
                                    .receiver
                                    ?.fullName ??
                                ''
                          : 'receiver_name'.tr,
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              width: 2,
                              color: Theme.of(context).cardColor,
                            ),
                            color: Theme.of(context).cardColor,
                          ),
                          child: ClipOval(
                            child: CustomImage(
                              image:
                                  '${_baseUrl(widget.notificationBody)}'
                                  '/${state.messageModel?.conversation?.receiver?.image ?? ''}',
                              fit: BoxFit.cover,
                              height: 40,
                              width: 40,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            body: isLoggedIn
                ? SafeArea(
                    child: Center(
                      child: SizedBox(
                        width: ResponsiveHelper.isDesktop(context)
                            ? Dimensions.webMaxWidth
                            : MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            // Message list
                            Expanded(
                              child: state.messageModel != null
                                  ? state.messageModel!.messages.isNotEmpty
                                        ? SingleChildScrollView(
                                            controller: _scrollController,
                                            reverse: true,
                                            child: PaginatedListView(
                                              scrollController:
                                                  _scrollController,
                                              reverse: true,
                                              totalSize:
                                                  state.messageModel?.totalSize,
                                              offset:
                                                  state.messageModel?.offset,
                                              onPaginate: (offset) =>
                                                  context.read<ChatBloc>().add(
                                                    MessagesRequested(
                                                      offset: offset!,
                                                      notificationBody: widget
                                                          .notificationBody,
                                                      user: widget.user,
                                                      conversationId:
                                                          widget.conversationID,
                                                    ),
                                                  ),
                                              itemView: ListView.builder(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                reverse: true,
                                                itemCount: state
                                                    .messageModel!
                                                    .messages
                                                    .length,
                                                itemBuilder: (_, index) =>
                                                    MessageBubbleWidget(
                                                      message: state
                                                          .messageModel!
                                                          .messages[index],
                                                      user: state
                                                          .messageModel!
                                                          .conversation!
                                                          .receiver,
                                                      userType: _userType(
                                                        widget.notificationBody,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Text('no_message_found'.tr),
                                          )
                                  : const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                            ),

                            // Input section
                            if (state.messageModel != null &&
                                (state.messageModel!.status == true ||
                                    state.messageModel!.messages.isEmpty))
                              Container(
                                color: Theme.of(context).cardColor,
                                child: Column(
                                  children: [
                                    // image preview
                                    if (state.chatImages.isNotEmpty)
                                      SizedBox(
                                        height: 100,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: state.chatImages.length,
                                          itemBuilder: (_, index) => Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  width: 100,
                                                  height: 100,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                              Radius.circular(
                                                                20,
                                                              ),
                                                            ),
                                                      ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                          Radius.circular(
                                                            Dimensions
                                                                .paddingSizeDefault,
                                                          ),
                                                        ),
                                                    child: Image.memory(
                                                      state
                                                          .chatRawImages[index],
                                                      width: 100,
                                                      height: 100,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: InkWell(
                                                    onTap: () => context
                                                        .read<ChatBloc>()
                                                        .add(
                                                          ChatImageRemoved(
                                                            index,
                                                            _inputMessageController
                                                                .text
                                                                .trim(),
                                                          ),
                                                        ),
                                                    child: Container(
                                                      decoration: const BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                              Radius.circular(
                                                                Dimensions
                                                                    .paddingSizeDefault,
                                                              ),
                                                            ),
                                                      ),
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(
                                                          4,
                                                        ),
                                                        child: Icon(
                                                          Icons.clear,
                                                          color: Colors.red,
                                                          size: 15,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                    // toolbar
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => context
                                              .read<ChatBloc>()
                                              .add(const ChatImagePicked()),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeDefault,
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
                                        SizedBox(
                                          height: 25,
                                          child: VerticalDivider(
                                            width: 0,
                                            thickness: 1,
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: Dimensions.paddingSizeDefault,
                                        ),
                                        Expanded(
                                          child: TextField(
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(
                                                Dimensions.messageInputLength,
                                              ),
                                            ],
                                            controller: _inputMessageController,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            style: robotoRegular,
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLines: null,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'type_here'.tr,
                                              hintStyle: robotoRegular.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).hintColor,
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                              ),
                                            ),
                                            onChanged: (text) {
                                              final active = text
                                                  .trim()
                                                  .isNotEmpty;
                                              if (active !=
                                                  state.isSendButtonActive) {
                                                context.read<ChatBloc>().add(
                                                  const ChatSendButtonToggled(),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        // send / loading
                                        state.isLoading
                                            ? const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: Dimensions
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
                                                        notificationBody: widget
                                                            .notificationBody,
                                                        conversationId: widget
                                                            .conversationID,
                                                        index: widget.index,
                                                      ),
                                                    );
                                                    _inputMessageController
                                                        .clear();
                                                  } else {
                                                    showCustomSnackBar(
                                                      'write_something'.tr,
                                                    );
                                                  }
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeDefault,
                                                      ),
                                                  child: Image.asset(
                                                    Images.send,
                                                    width: 25,
                                                    height: 25,
                                                    color:
                                                        state.isSendButtonActive
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
                  )
                : NotLoggedInScreen(
                    callBack: (_) {
                      context.read<ChatBloc>().add(
                        MessagesRequested(
                          offset: 1,
                          notificationBody: widget.notificationBody,
                          user: widget.user,
                          conversationId: widget.conversationID,
                          firstLoad: true,
                        ),
                      );
                      setState(() {});
                    },
                  ),
          ),
        );
      },
    );
  }
}
