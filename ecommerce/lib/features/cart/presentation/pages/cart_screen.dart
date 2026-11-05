import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';
import 'package:ecommerce/features/cart/presentation/widgets/not_available_bottom_sheet_widget.dart';
import 'package:ecommerce/features/coupon/presentation/bloc/coupon_bloc.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/store/controllers/store_controller.dart';
import 'package:ecommerce/features/cart/data/models/cart_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/item_widget.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/common/widgets/no_data_screen.dart';
import 'package:ecommerce/common/widgets/web_constrained_box.dart';
import 'package:ecommerce/common/widgets/web_page_title_widget.dart';
import 'package:ecommerce/features/cart/presentation/widgets/cart_item_widget.dart';
import 'package:ecommerce/features/cart/presentation/widgets/web_cart_items_widget.dart';
import 'package:ecommerce/features/cart/presentation/widgets/web_suggested_item_view_widget.dart';
import 'package:ecommerce/features/home/screens/home_screen.dart';
import 'package:ecommerce/features/store/screens/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartScreen extends StatefulWidget {
  final bool fromNav;
  const CartScreen({super.key, required this.fromNav});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    final cartBloc = context.read<CartBloc>();
    if (cartBloc.state.cartList.isEmpty) {
      cartBloc.add(const CartDataOnlineRequested());
    } else {
      if (cartBloc.state.addCutlery) {
        cartBloc.add(const CartCutleryToggled());
      }
      cartBloc.add(const CartNotAvailableIndexSet(-1));
      Get.find<StoreController>().getCartStoreSuggestedItemList(
        cartBloc.state.cartList[0].item!.storeId,
      );
      Get.find<StoreController>().getStoreDetails(
        Store(id: cartBloc.state.cartList[0].item!.storeId, name: null),
        false,
        fromCart: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartBloc, CartState>(
      listenWhen: (p, c) =>
          p.status != c.status && c.status == CartStatus.loaded,
      listener: (context, state) {
        if (state.cartList.isNotEmpty) {
          Get.find<StoreController>().getCartStoreSuggestedItemList(
            state.cartList[0].item!.storeId,
          );
          Get.find<StoreController>().getStoreDetails(
            Store(id: state.cartList[0].item!.storeId, name: null),
            false,
            fromCart: true,
          );
        }
      },
      builder: (context, cartState) {
        final List<CartModel> cartList = cartState.cartList;
        return Scaffold(
          appBar: CustomAppBar(
            title: 'my_cart'.tr,
            backButton:
                (ResponsiveHelper.isDesktop(context) || !widget.fromNav),
          ),
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          body: cartList.isNotEmpty
              ? Column(
                  children: [
                    WebScreenTitleWidget(title: 'cart_list'.tr),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: ResponsiveHelper.isDesktop(context)
                            ? const EdgeInsets.only(
                                top: Dimensions.paddingSizeSmall,
                              )
                            : EdgeInsets.zero,
                        child: FooterView(
                          child: SizedBox(
                            width: Dimensions.webMaxWidth,
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (ResponsiveHelper.isDesktop(context))
                                      WebCardItemsWidget(cartList: cartList)
                                    else
                                      Expanded(
                                        flex: 7,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            WebConstrainedBox(
                                              dataLength: cartList.length,
                                              minLength: 5,
                                              minHeight: 0.6,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ListView.builder(
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    itemCount: cartList.length,
                                                    padding: const EdgeInsets.all(
                                                      Dimensions
                                                          .paddingSizeDefault,
                                                    ),
                                                    itemBuilder: (_, index) =>
                                                        CartItemWidget(
                                                          cart: cartList[index],
                                                          cartIndex: index,
                                                          addOns:
                                                              cartState
                                                                  .addOnsList
                                                                  .isNotEmpty
                                                              ? cartState
                                                                    .addOnsList[index]
                                                              : const [],
                                                          isAvailable:
                                                              cartState
                                                                  .availableList
                                                                  .isNotEmpty
                                                              ? cartState
                                                                    .availableList[index]
                                                              : true,
                                                        ),
                                                  ),
                                                  const Divider(
                                                    thickness: 0.5,
                                                    height: 5,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                      left: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),
                                                    child: TextButton.icon(
                                                      onPressed: () {
                                                        context
                                                            .read<CartBloc>()
                                                            .add(
                                                              CartModuleForcefullySet(
                                                                cartList[0]
                                                                    .item!
                                                                    .moduleId!,
                                                              ),
                                                            );
                                                        Get.toNamed(
                                                          RouteHelper.getStoreRoute(
                                                            id: cartList[0]
                                                                .item!
                                                                .storeId,
                                                            page: 'item',
                                                          ),
                                                          arguments: StoreScreen(
                                                            store: Store(
                                                              id: cartList[0]
                                                                  .item!
                                                                  .storeId,
                                                            ),
                                                            fromModule: false,
                                                          ),
                                                        );
                                                      },
                                                      icon: Icon(
                                                        Icons
                                                            .add_circle_outline_sharp,
                                                        color: Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                      ),
                                                      label: Text(
                                                        'add_more_items'.tr,
                                                        style: robotoMedium.copyWith(
                                                          color: Theme.of(
                                                            context,
                                                          ).primaryColor,
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  _suggestedItemView(
                                                    context,
                                                    cartList,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeSmall,
                                            ),
                                            _pricingView(
                                              context,
                                              cartState,
                                              cartList[0].item!,
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (ResponsiveHelper.isDesktop(context))
                                      const SizedBox(
                                        width: Dimensions.paddingSizeSmall,
                                      ),
                                    if (ResponsiveHelper.isDesktop(context))
                                      Expanded(
                                        flex: 4,
                                        child: _pricingView(
                                          context,
                                          cartState,
                                          cartList[0].item!,
                                        ),
                                      ),
                                  ],
                                ),
                                if (ResponsiveHelper.isDesktop(context))
                                  WebSuggestedItemViewWidget(
                                    cartList: cartList,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!ResponsiveHelper.isDesktop(context))
                      _CheckoutButton(
                        cartState: cartState,
                        availableList: cartState.availableList,
                      ),
                  ],
                )
              : const NoDataScreen(isCart: true, text: '', showFooter: true),
        );
      },
    );
  }

  Widget _pricingView(BuildContext context, CartState cartState, Item item) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.isDesktop(context)
              ? Dimensions.radiusDefault
              : Dimensions.radiusSmall,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: GetBuilder<StoreController>(
        builder: (storeController) {
          return Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  child: Text(
                    'order_summary'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                ),
              ),

              // Cutlery toggle (mobile only)
              if (!ResponsiveHelper.isDesktop(context) &&
                  Get.find<SplashController>()
                      .getModuleConfig(item.moduleType)
                      .newVariation! &&
                  (storeController.store?.cutlery ?? false))
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  child: Row(
                    children: [
                      Image.asset(Images.cutlery, height: 18, width: 18),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'add_cutlery'.tr,
                              style: robotoMedium.copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall,
                            ),
                            Text(
                              'do_not_have_cutlery'.tr,
                              style: robotoRegular.copyWith(
                                color: Theme.of(context).disabledColor,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Transform.scale(
                        scale: 0.7,
                        child: CupertinoSwitch(
                          value: cartState.addCutlery,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (_) => context.read<CartBloc>().add(
                            const CartCutleryToggled(),
                          ),
                          trackColor: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),

              // Not-available option (mobile)
              if (!ResponsiveHelper.isDesktop(context))
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 0.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const NotAvailableBottomSheetWidget(),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'if_any_product_is_not_available'.tr,
                                style: robotoMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_sharp, size: 18),
                          ],
                        ),
                      ),
                      if (cartState.notAvailableIndex != -1)
                        Row(
                          children: [
                            Text(
                              NotAvailableBottomSheetWidget
                                  .options[cartState.notAvailableIndex]
                                  .tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            IconButton(
                              onPressed: () => context.read<CartBloc>().add(
                                const CartNotAvailableIndexSet(-1),
                              ),
                              icon: const Icon(Icons.clear, size: 18),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              // Totals
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('item_price'.tr, style: robotoRegular),
                        PriceConverter.convertAnimationPrice(
                          cartState.itemPrice,
                          textStyle: robotoRegular,
                        ),
                      ],
                    ),
                    if (Get.find<SplashController>()
                            .getModuleConfig(item.moduleType)
                            .newVariation! &&
                        cartState.variationPrice > 0) ...[
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('variations'.tr, style: robotoRegular),
                          Text(
                            '(+) ${PriceConverter.convertPrice(cartState.variationPrice)}',
                            style: robotoRegular,
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('discount'.tr, style: robotoRegular),
                        storeController.store != null
                            ? Row(
                                children: [
                                  Text('(-)', style: robotoRegular),
                                  PriceConverter.convertAnimationPrice(
                                    cartState.itemDiscountPrice,
                                    textStyle: robotoRegular,
                                  ),
                                ],
                              )
                            : Text('calculating'.tr, style: robotoRegular),
                      ],
                    ),
                    if (Get.find<SplashController>()
                        .configModel!
                        .moduleConfig!
                        .module!
                        .addOn!) ...[
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('addons'.tr, style: robotoRegular),
                          Text(
                            '(+) ${PriceConverter.convertPrice(cartState.addOns)}',
                            style: robotoRegular,
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              if (ResponsiveHelper.isDesktop(context))
                _CheckoutButton(
                  cartState: cartState,
                  availableList: cartState.availableList,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _suggestedItemView(BuildContext context, List<CartModel> cartList) {
    return Container(
      color: Theme.of(context).cardColor,
      width: double.infinity,
      child: GetBuilder<StoreController>(
        builder: (storeController) {
          List<Item>? suggestedItems;
          if (storeController.cartSuggestItemModel != null) {
            suggestedItems = [];
            final List<int> cartIds = cartList.map((c) => c.item!.id!).toList();
            for (final Item item
                in storeController.cartSuggestItemModel!.items!) {
              if (!cartIds.contains(item.id)) {
                suggestedItems.add(item);
              }
            }
          }
          if (suggestedItems == null || suggestedItems.isEmpty) {
            return const SizedBox();
          }
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
                height: ResponsiveHelper.isDesktop(context) ? 160 : 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: suggestedItems.length,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.paddingSizeExtraSmall
                        : Dimensions.paddingSizeDefault,
                  ),
                  itemBuilder: (_, index) => Padding(
                    padding: ResponsiveHelper.isDesktop(context)
                        ? const EdgeInsets.symmetric(vertical: 20)
                        : const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      width: ResponsiveHelper.isDesktop(context) ? 500 : 300,
                      padding: const EdgeInsets.only(
                        right: Dimensions.paddingSizeSmall,
                        left: Dimensions.paddingSizeExtraSmall,
                      ),
                      margin: const EdgeInsets.only(
                        right: Dimensions.paddingSizeSmall,
                      ),
                      child: ItemWidget(
                        isStore: false,
                        item: suggestedItems![index],
                        fromCartSuggestion: true,
                        store: null,
                        index: index,
                        length: null,
                        isCampaign: false,
                        inStore: true,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Checkout button ─────────────────────────────────────────────────────────

class _CheckoutButton extends StatelessWidget {
  final CartState cartState;
  final List<bool> availableList;
  const _CheckoutButton({required this.cartState, required this.availableList});

  @override
  Widget build(BuildContext context) {
    double percentage = 0;
    return Container(
      width: Dimensions.webMaxWidth,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.isDesktop(context) ? Dimensions.radiusDefault : 0,
        ),
        boxShadow: ResponsiveHelper.isDesktop(context)
            ? null
            : [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ],
      ),
      child: GetBuilder<StoreController>(
        builder: (storeController) {
          if (storeController.store != null &&
              !storeController.store!.freeDelivery! &&
              Get.find<SplashController>().configModel!.freeDeliveryOver !=
                  null) {
            percentage =
                cartState.subTotal /
                Get.find<SplashController>().configModel!.freeDeliveryOver!;
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (storeController.store != null &&
                  !storeController.store!.freeDelivery! &&
                  Get.find<SplashController>().configModel!.freeDeliveryOver !=
                      null &&
                  percentage < 1) ...[
                Row(
                  children: [
                    Image.asset(Images.percentTag, height: 20, width: 20),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(
                      PriceConverter.convertPrice(
                        Get.find<SplashController>()
                                .configModel!
                                .freeDeliveryOver! -
                            cartState.subTotal,
                      ),
                      style: robotoMedium.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(
                      'more_for_free_delivery'.tr,
                      style: robotoMedium.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                LinearProgressIndicator(
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.2),
                  value: percentage,
                ),
              ],

              if (ResponsiveHelper.isDesktop(context)) const Divider(height: 1),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Padding(
                padding: const EdgeInsets.only(
                  bottom: Dimensions.paddingSizeSmall,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'subtotal'.tr,
                      style: robotoMedium.copyWith(
                        color: ResponsiveHelper.isDesktop(context)
                            ? Theme.of(context).textTheme.bodyLarge!.color
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                    PriceConverter.convertAnimationPrice(
                      cartState.subTotal,
                      textStyle: robotoRegular.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Cutlery toggle (desktop)
              if (ResponsiveHelper.isDesktop(context) &&
                  cartState.cartList.isNotEmpty &&
                  Get.find<SplashController>()
                      .getModuleConfig(cartState.cartList[0].item!.moduleType)
                      .newVariation! &&
                  (storeController.store?.cutlery ?? false))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: Row(
                    children: [
                      Image.asset(Images.cutlery, height: 18, width: 18),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'add_cutlery'.tr,
                              style: robotoMedium.copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall,
                            ),
                            Text(
                              'do_not_have_cutlery'.tr,
                              style: robotoRegular.copyWith(
                                color: Theme.of(context).disabledColor,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Transform.scale(
                        scale: 0.7,
                        child: CupertinoSwitch(
                          value: cartState.addCutlery,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (_) => context.read<CartBloc>().add(
                            const CartCutleryToggled(),
                          ),
                          trackColor: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),

              if (ResponsiveHelper.isDesktop(context)) ...[
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Container(
                  width: Dimensions.webMaxWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Theme.of(context).cardColor,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 0.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => Get.dialog(
                          const Dialog(child: NotAvailableBottomSheetWidget()),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'if_any_product_is_not_available'.tr,
                                style: robotoMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, size: 18),
                          ],
                        ),
                      ),
                      if (cartState.notAvailableIndex != -1)
                        Row(
                          children: [
                            Text(
                              NotAvailableBottomSheetWidget
                                  .options[cartState.notAvailableIndex]
                                  .tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            IconButton(
                              onPressed: () => context.read<CartBloc>().add(
                                const CartNotAvailableIndexSet(-1),
                              ),
                              icon: const Icon(Icons.clear, size: 18),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
              ],

              SafeArea(
                child: CustomButton(
                  buttonText: 'proceed_to_checkout'.tr,
                  fontSize: ResponsiveHelper.isDesktop(context)
                      ? Dimensions.fontSizeSmall
                      : Dimensions.fontSizeLarge,
                  isBold: !ResponsiveHelper.isDesktop(context),
                  radius: ResponsiveHelper.isDesktop(context)
                      ? Dimensions.radiusSmall
                      : Dimensions.radiusDefault,
                  onPressed: () {
                    if (cartState.cartList.isNotEmpty &&
                        !cartState.cartList.first.item!.scheduleOrder! &&
                        availableList.contains(false)) {
                      showCustomSnackBar('one_or_more_product_unavailable'.tr);
                      return;
                    }
                    if (Get.find<SplashController>().module == null &&
                        cartState.cartList.isNotEmpty) {
                      final modules =
                          Get.find<SplashController>().moduleList ?? [];
                      int i = 0;
                      for (; i < modules.length; i++) {
                        if (cartState.cartList[0].item!.moduleId ==
                            modules[i].id)
                          break;
                      }
                      if (i < modules.length) {
                        Get.find<SplashController>().setModule(modules[i]);
                        HomeScreen.loadData(true);
                      }
                    }
                    context.read<CouponBloc>().add(const CouponDataRemoved());
                    Get.toNamed(RouteHelper.getCheckoutRoute('cart'));
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
