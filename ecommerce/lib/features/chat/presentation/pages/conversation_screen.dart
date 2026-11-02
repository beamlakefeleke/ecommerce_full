import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:ecommerce/features/chat/presentation/bloc/chat_event.dart';
import 'package:ecommerce/features/chat/presentation/bloc/chat_state.dart';
import 'package:ecommerce/features/chat/enums/user_type_enum.dart';
import 'package:ecommerce/features/language/controllers/language_controller.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/profile/controllers/profile_controller.dart';
import 'package:ecommerce/features/notification/domain/models/notification_body_model.dart';
import 'package:ecommerce/features/chat/domain/entities/conversation.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/date_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'package:ecommerce/common/widgets/custom_ink_well.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/common/widgets/not_logged_in_screen.dart';
import 'package:ecommerce/common/widgets/paginated_list_view.dart';
import 'package:ecommerce/features/search/widgets/search_field_widget.dart';
import 'package:ecommerce/features/chat/presentation/widgets/web_chat_view_widget.dart';
import 'package:get/get.dart';

class ConversationScreen extends StatefulWidget {
  final bool fromNavBar;
  const ConversationScreen({super.key, this.fromNavBar = false});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (AuthHelper.isLoggedIn()) {
      Get.find<ProfileController>().getUserInfo();
      context.read<ChatBloc>().add(
        ConversationListRequested(
          offset: 1,
          type: ResponsiveHelper.isDesktop(context) ? 'vendor' : '',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final convList = state.searchConversationList ?? state.conversationList;

        return Scaffold(
          appBar: CustomAppBar(
            title: 'conversation_list'.tr,
            backButton: !widget.fromNavBar,
          ),
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          floatingActionButton:
              (state.conversationList != null &&
                  !state.hasAdmin &&
                  !ResponsiveHelper.isDesktop(context))
              ? FloatingActionButton.extended(
                  label: SizedBox(
                    width: context.width * 0.75,
                    child: Text(
                      '${'chat_with'.tr} ${Get.find<SplashController>().configModel!.businessName}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.chat, color: Colors.white),
                  backgroundColor: Theme.of(context).primaryColor,
                  onPressed: () => Get.toNamed(
                    RouteHelper.getChatRoute(
                      notificationBody: NotificationBodyModel(
                        notificationType: NotificationType.message,
                        adminId: 0,
                      ),
                    ),
                  ),
                )
              : null,
          body: ResponsiveHelper.isDesktop(context)
              ? WebChatViewWidget(
                  scrollController: _scrollController,
                  searchController: _searchController,
                )
              : Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Column(
                    children: [
                      if (AuthHelper.isLoggedIn() &&
                          convList != null &&
                          convList.conversations.isNotEmpty)
                        Center(
                          child: SizedBox(
                            width: Dimensions.webMaxWidth,
                            child: SearchFieldWidget(
                              controller: _searchController,
                              hint: 'search'.tr,
                              suffixIcon: state.searchConversationList != null
                                  ? Icons.close
                                  : Icons.search,
                              onSubmit: (text) {
                                if (text.trim().isNotEmpty) {
                                  context.read<ChatBloc>().add(
                                    ConversationSearchRequested(text.trim()),
                                  );
                                } else {
                                  showCustomSnackBar('write_something'.tr);
                                }
                              },
                              iconPressed: () {
                                if (state.searchConversationList != null) {
                                  _searchController.clear();
                                  context.read<ChatBloc>().add(
                                    const ConversationSearchCleared(),
                                  );
                                } else if (_searchController.text
                                    .trim()
                                    .isNotEmpty) {
                                  context.read<ChatBloc>().add(
                                    ConversationSearchRequested(
                                      _searchController.text.trim(),
                                    ),
                                  );
                                } else {
                                  showCustomSnackBar('write_something'.tr);
                                }
                              },
                            ),
                          ),
                        ),
                      if (AuthHelper.isLoggedIn() &&
                          convList != null &&
                          convList.conversations.isNotEmpty)
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: AuthHelper.isLoggedIn()
                            ? (convList != null)
                                  ? convList.conversations.isNotEmpty
                                        ? RefreshIndicator(
                                            onRefresh: () async {
                                              context.read<ChatBloc>().add(
                                                const ConversationListRequested(),
                                              );
                                            },
                                            child: SingleChildScrollView(
                                              controller: _scrollController,
                                              padding: EdgeInsets.zero,
                                              child: FooterView(
                                                child: SizedBox(
                                                  width: Dimensions.webMaxWidth,
                                                  child: PaginatedListView(
                                                    scrollController:
                                                        _scrollController,
                                                    onPaginate: (offset) => context
                                                        .read<ChatBloc>()
                                                        .add(
                                                          ConversationListRequested(
                                                            offset: offset!,
                                                          ),
                                                        ),
                                                    totalSize:
                                                        convList.totalSize,
                                                    offset: convList.offset,
                                                    enabledPagination:
                                                        state
                                                            .searchConversationList ==
                                                        null,
                                                    itemView: ListView.builder(
                                                      itemCount: convList
                                                          .conversations
                                                          .length,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder:
                                                          (
                                                            context,
                                                            index,
                                                          ) => _ConversationTile(
                                                            conversation: convList
                                                                .conversations[index],
                                                            index: index,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                              'no_conversation_found'.tr,
                                            ),
                                          )
                                  : const Center(
                                      child: CircularProgressIndicator(),
                                    )
                            : NotLoggedInScreen(
                                callBack: (_) {
                                  context.read<ChatBloc>().add(
                                    const ConversationListRequested(),
                                  );
                                  setState(() {});
                                },
                              ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final int index;
  const _ConversationTile({required this.conversation, required this.index});

  @override
  Widget build(BuildContext context) {
    final bool isUserSender =
        conversation.senderType == UserType.user.name ||
        conversation.senderType == UserType.customer.name;
    final ChatUser? user = isUserSender
        ? conversation.receiver
        : conversation.sender;
    final String? type = isUserSender
        ? conversation.receiverType
        : conversation.senderType;

    String baseUrl = '';
    if (type == UserType.vendor.name) {
      baseUrl =
          Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl ??
          '';
    } else if (type == UserType.delivery_man.name) {
      baseUrl =
          Get.find<SplashController>()
              .configModel!
              .baseUrls!
              .deliveryManImageUrl ??
          '';
    } else if (type == UserType.admin.name) {
      baseUrl =
          Get.find<SplashController>().configModel!.baseUrls!.businessLogoUrl ??
          '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: const [
          BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5),
        ],
      ),
      child: CustomInkWell(
        onTap: () {
          if (user != null) {
            Get.toNamed(
              RouteHelper.getChatRoute(
                notificationBody: NotificationBodyModel(
                  type: conversation.senderType,
                  notificationType: NotificationType.message,
                  adminId: type == UserType.admin.name ? 0 : null,
                  restaurantId: type == UserType.vendor.name ? user.id : null,
                  deliverymanId: type == UserType.delivery_man.name
                      ? user.id
                      : null,
                ),
                conversationID: conversation.id,
                index: index,
              ),
            );
          } else {
            showCustomSnackBar('${(type ?? '').tr} ${'not_found'.tr}');
          }
        },
        highlightColor: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: 0.1),
        radius: Dimensions.radiusSmall,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Row(
                children: [
                  ClipOval(
                    child: CustomImage(
                      height: 50,
                      width: 50,
                      image: '$baseUrl/${user?.image ?? ''}',
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        user != null
                            ? Text(user.fullName, style: robotoMedium)
                            : Text(
                                '${'${type ?? ''}'.tr} ${'deleted'.tr}',
                                style: robotoMedium,
                              ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall,
                        ),
                        if (user != null)
                          Text(
                            (type ?? '').tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: Get.find<LocalizationController>().isLtr ? 5 : null,
              bottom: 5,
              left: Get.find<LocalizationController>().isLtr ? null : 5,
              child: Text(
                conversation.lastMessageTime != null
                    ? DateConverter.localDateToIsoStringAMPM(
                        DateConverter.dateTimeStringToDate(
                          conversation.lastMessageTime!,
                        ),
                      )
                    : '',
                style: robotoRegular.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: Dimensions.fontSizeExtraSmall,
                ),
              ),
            ),
            GetBuilder<ProfileController>(
              builder: (profileController) {
                final bool hasUnread =
                    profileController.userInfoModel != null &&
                    profileController.userInfoModel!.userInfo != null &&
                    conversation.lastMessage?.senderId !=
                        profileController.userInfoModel!.userInfo!.id &&
                    (conversation.unreadMessageCount ?? 0) > 0;
                if (!hasUnread) return const SizedBox();
                return Positioned(
                  right: Get.find<LocalizationController>().isLtr ? 5 : null,
                  top: 5,
                  left: Get.find<LocalizationController>().isLtr ? null : 5,
                  child: Container(
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeExtraSmall,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      conversation.unreadMessageCount.toString(),
                      style: robotoMedium.copyWith(
                        color: Theme.of(context).cardColor,
                        fontSize: Dimensions.fontSizeExtraSmall,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
