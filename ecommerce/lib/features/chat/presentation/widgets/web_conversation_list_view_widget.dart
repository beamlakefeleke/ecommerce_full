import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:ecommerce/features/chat/domain/entities/conversation.dart';
import 'package:ecommerce/features/chat/enums/user_type_enum.dart';
import 'package:ecommerce/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:ecommerce/features/chat/presentation/bloc/chat_event.dart';
import 'package:ecommerce/features/chat/presentation/bloc/chat_state.dart';
import 'package:ecommerce/features/language/controllers/language_controller.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/profile/controllers/profile_controller.dart';
import 'package:ecommerce/features/notification/domain/models/notification_body_model.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/date_converter.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'package:ecommerce/common/widgets/custom_ink_well.dart';
import 'package:ecommerce/common/widgets/paginated_list_view.dart';
import 'package:get/get.dart';

/// Conversation list for the web chat view. Reads [ChatBloc].
class WebConversationListViewWidget extends StatefulWidget {
  final ScrollController scrollController;
  final String type;
  final void Function(ChatUser? user) onUserSelected;

  const WebConversationListViewWidget({
    super.key,
    required this.scrollController,
    required this.type,
    required this.onUserSelected,
  });

  @override
  State<WebConversationListViewWidget> createState() =>
      _WebConversationListViewWidgetState();
}

class _WebConversationListViewWidgetState
    extends State<WebConversationListViewWidget> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(
      ConversationListRequested(offset: 1, type: widget.type),
    );
  }

  String? _baseUrlFor(String? type) {
    final urls = Get.find<SplashController>().configModel!.baseUrls!;
    if (type == UserType.vendor.name) return urls.storeImageUrl;
    if (type == UserType.delivery_man.name) return urls.deliveryManImageUrl;
    if (type == UserType.admin.name) return urls.businessLogoUrl;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final ConversationList? conversation =
            state.searchConversationList ?? state.conversationList;

        if (conversation == null) {
          return const ConversationShimmer();
        }
        if (conversation.conversations.isEmpty) {
          return Center(child: Text('no_conversation_found'.tr));
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<ChatBloc>().add(
              ConversationListRequested(offset: 1, type: widget.type),
            );
          },
          child: SingleChildScrollView(
            controller: widget.scrollController,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: PaginatedListView(
                scrollController: widget.scrollController,
                onPaginate: (int? offset) => context.read<ChatBloc>().add(
                  ConversationListRequested(
                    offset: offset ?? 1,
                    type: widget.type,
                  ),
                ),
                totalSize: conversation.totalSize,
                offset: conversation.offset,
                enabledPagination: state.searchConversationList == null,
                itemView: ListView.builder(
                  itemCount: conversation.conversations.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final convo = conversation.conversations[index];
                    final bool senderIsCustomer =
                        convo.senderType == UserType.user.name ||
                        convo.senderType == UserType.customer.name;
                    final ChatUser? user = senderIsCustomer
                        ? convo.receiver
                        : convo.sender;
                    final String? type = senderIsCustomer
                        ? convo.receiverType
                        : convo.senderType;
                    final String baseUrl = _baseUrlFor(type) ?? '';
                    final bool selected =
                        state.selectedIndex == index && state.type == type;

                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: selected
                                ? Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.10)
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSmall,
                            ),
                          ),
                          child: CustomInkWell(
                            onTap: () {
                              if (!AuthHelper.isLoggedIn()) return;
                              final body = NotificationBodyModel(
                                type: convo.senderType,
                                notificationType: NotificationType.message,
                                adminId: type == UserType.admin.name ? 0 : null,
                                restaurantId: type == UserType.vendor.name
                                    ? user?.id
                                    : null,
                                deliverymanId:
                                    type == UserType.delivery_man.name
                                    ? user?.id
                                    : null,
                                conversationId: convo.id,
                                index: index,
                                image:
                                    '$baseUrl/${user != null ? user.image : ''}',
                                name: user != null ? user.fullName : '',
                                receiverType: type,
                              );
                              context.read<ChatBloc>().add(
                                MessagesRequested(
                                  offset: 1,
                                  notificationBody: body,
                                  user: user,
                                  conversationId: convo.id,
                                  firstLoad: true,
                                ),
                              );
                              final profile = Get.find<ProfileController>();
                              if (profile.userInfoModel == null ||
                                  profile.userInfoModel!.userInfo == null) {
                                profile.getUserInfo();
                              }
                              context.read<ChatBloc>().add(
                                ChatNotificationBodySet(body),
                              );
                              context.read<ChatBloc>().add(
                                ChatSelectedIndexSet(index),
                              );
                              widget.onUserSelected(user);
                            },
                            highlightColor: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.1),
                            radius: Dimensions.radiusSmall,
                            child: Stack(
                              children: [
                                Padding(
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
                                              '$baseUrl/${user != null ? user.image : ''}',
                                        ),
                                      ),
                                      const SizedBox(
                                        width: Dimensions.paddingSizeSmall,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            user != null
                                                ? Text(
                                                    user.fullName,
                                                    style: robotoMedium,
                                                  )
                                                : Text(
                                                    '${type?.tr ?? ''} ${'deleted'.tr}',
                                                    style: robotoMedium,
                                                  ),
                                            const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),
                                            if (convo.lastMessage != null)
                                              Text(
                                                convo.lastMessage!.message ??
                                                    '',
                                                style: robotoRegular.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
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
                                ),
                                if (convo.lastMessageTime != null)
                                  Positioned(
                                    right:
                                        Get.find<LocalizationController>().isLtr
                                        ? 5
                                        : null,
                                    top: 15,
                                    left:
                                        Get.find<LocalizationController>().isLtr
                                        ? null
                                        : 5,
                                    child: Text(
                                      DateConverter.convertOnlyTodayTime(
                                        convo.lastMessageTime!,
                                      ),
                                      style: robotoRegular.copyWith(
                                        color: Theme.of(context).hintColor,
                                        fontSize: Dimensions.fontSizeExtraSmall,
                                      ),
                                    ),
                                  ),
                                GetBuilder<ProfileController>(
                                  builder: (profileController) {
                                    final showBadge =
                                        profileController.userInfoModel !=
                                            null &&
                                        profileController
                                                .userInfoModel!
                                                .userInfo !=
                                            null &&
                                        convo.lastMessage?.senderId !=
                                            profileController
                                                .userInfoModel!
                                                .userInfo!
                                                .id &&
                                        (convo.unreadMessageCount ?? 0) > 0;
                                    if (!showBadge) return const SizedBox();
                                    return Positioned(
                                      right:
                                          Get.find<LocalizationController>()
                                              .isLtr
                                          ? 5
                                          : null,
                                      bottom: 8,
                                      left:
                                          Get.find<LocalizationController>()
                                              .isLtr
                                          ? null
                                          : 5,
                                      child: Container(
                                        padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeExtraSmall,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          convo.unreadMessageCount.toString(),
                                          style: robotoMedium.copyWith(
                                            color: Theme.of(context).cardColor,
                                            fontSize:
                                                Dimensions.fontSizeExtraSmall,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (index + 1 != conversation.conversations.length)
                          Divider(
                            color: Theme.of(
                              context,
                            ).disabledColor.withValues(alpha: .5),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ConversationShimmer extends StatelessWidget {
  const ConversationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: Container(
                          height: 50,
                          width: 50,
                          color: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 10,
                              width: Get.width * 0.5,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall,
                            ),
                            Container(
                              height: 10,
                              width: Get.width * 0.3,
                              color: Colors.grey[300],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Theme.of(
                      context,
                    ).disabledColor.withValues(alpha: .5),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
