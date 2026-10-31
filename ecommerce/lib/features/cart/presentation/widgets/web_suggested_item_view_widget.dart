import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/features/store/controllers/store_controller.dart';
import 'package:ecommerce/features/cart/data/models/cart_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/item_widget.dart';
import 'package:get/get.dart';

class WebSuggestedItemViewWidget extends StatelessWidget {
  final List<CartModel> cartList;
  const WebSuggestedItemViewWidget({super.key, required this.cartList});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GetBuilder<StoreController>(
            builder: (storeController) {
              List<Item>? suggestedItems;
              if (storeController.cartSuggestItemModel != null) {
                suggestedItems = [];
                final List<int> cartIds = cartList
                    .map((c) => c.item!.id!)
                    .toList();
                for (final Item item
                    in storeController.cartSuggestItemModel!.items!) {
                  if (!cartIds.contains(item.id)) {
                    suggestedItems.add(item);
                  }
                }
              }
              if (storeController.cartSuggestItemModel == null ||
                  (suggestedItems?.isEmpty ?? true)) {
                return const SizedBox();
              }
              return BlocBuilder<CartBloc, CartState>(
                buildWhen: (p, c) => p.currentIndex != c.currentIndex,
                builder: (context, cartState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeExtraSmall,
                        ),
                        child: Text(
                          'you_may_also_like'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.isDesktop(context) ? 110 : 125,
                        child: PageView.builder(
                          controller: pageController,
                          itemCount: (suggestedItems!.length / 4).ceil(),
                          onPageChanged: (index) => context
                              .read<CartBloc>()
                              .add(CartCurrentIndexChanged(index)),
                          itemBuilder: (context, pageIndex) {
                            final int i1 = pageIndex * 4;
                            final int i2 = i1 + 1;
                            final int i3 = i1 + 2;
                            final int i4 = i1 + 3;
                            return Stack(
                              children: [
                                Row(
                                  children: [
                                    for (final int idx in [
                                      i1,
                                      i2,
                                      i3,
                                      i4,
                                    ].where((i) => i < suggestedItems!.length))
                                      Container(
                                        width: 282.5,
                                        margin: const EdgeInsets.only(
                                          right: Dimensions.paddingSizeSmall,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical:
                                              Dimensions.paddingSizeExtraSmall,
                                        ),
                                        child: ItemWidget(
                                          imageHeight: 90,
                                          imageWidth: 90,
                                          isCornerTag: true,
                                          isStore: false,
                                          item: suggestedItems![idx],
                                          fromCartSuggestion: true,
                                          store: null,
                                          index: pageIndex,
                                          length: null,
                                          isCampaign: false,
                                          inStore: true,
                                        ),
                                      ),
                                  ],
                                ),
                                if (cartState.currentIndex != 0)
                                  Positioned(
                                    top: 0,
                                    bottom: 0,
                                    left: 0,
                                    child: InkWell(
                                      onTap: () => pageController.previousPage(
                                        duration: const Duration(seconds: 1),
                                        curve: Curves.easeInOut,
                                      ),
                                      child: Container(
                                        height: 30,
                                        width: 30,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context).cardColor,
                                        ),
                                        child: const Icon(
                                          Icons.keyboard_arrow_left,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (cartState.currentIndex !=
                                    (suggestedItems!.length / 4).ceil() - 1)
                                  Positioned(
                                    top: 0,
                                    bottom: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: () => pageController.nextPage(
                                        duration: const Duration(seconds: 1),
                                        curve: Curves.easeInOut,
                                      ),
                                      child: Container(
                                        height: 30,
                                        width: 30,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context).cardColor,
                                        ),
                                        child: const Icon(
                                          Icons.keyboard_arrow_right,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
