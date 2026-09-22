import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/cart/widgets/not_available_bottom_sheet_widget.dart';
import 'package:ecommerce/features/coupon/controllers/coupon_controller.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/store/controllers/store_controller.dart';
import 'package:ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:ecommerce/features/cart/domain/entities/cart.dart';
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
import 'package:ecommerce/features/cart/widgets/cart_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/cart/widgets/web_cart_items_widget.dart';
import 'package:ecommerce/features/cart/widgets/web_suggested_item_view_widget.dart';
import 'package:ecommerce/features/home/screens/home_screen.dart';
import 'package:ecommerce/features/store/screens/store_screen.dart';

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

    initCall();

  }

  void initCall() {
    final cartBloc = getIt<CartBloc>();
    if(cartBloc.state.cartList.isEmpty) {
      cartBloc.add(GetCartDataEvent());
    }
    _loadStoreData(cartBloc.state.cartList);
  }

  void _loadStoreData(List<Cart> cartList) {
    if(cartList.isNotEmpty){
      Get.find<StoreController>().getCartStoreSuggestedItemList(cartList[0].item!.storeId);
      Get.find<StoreController>().getStoreDetails(Store(id: cartList[0].item!.storeId, name: null), false, fromCart: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'my_cart'.tr, backButton: (ResponsiveHelper.isDesktop(context) || !widget.fromNav)),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: BlocBuilder<CartBloc, CartState>(bloc: getIt<CartBloc>(), builder: (context, cartState) {
        return cartState.cartList.isNotEmpty ? Column(
          children: [
            WebScreenTitleWidget(title: 'cart_list'.tr),

             Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.only(
                  top: Dimensions.paddingSizeSmall,
                ) : EdgeInsets.zero,
                child: FooterView(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Column(children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ResponsiveHelper.isDesktop(context) ? WebCardItemsWidget(cartList: cartState.cartList) :
                          Expanded(
                            flex: 7,
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                              WebConstrainedBox(
                                dataLength: cartState.cartList.length, minLength: 5, minHeight: 0.6,
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: cartState.cartList.length,
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                    itemBuilder: (context, index) {
                                      return CartItemWidget(cart: cartState.cartList[index], cartIndex: index, addOns: cartState.addOnsList[index], isAvailable: cartState.availableList[index]);
                                    },
                                  ),

                                  const Divider(thickness: 0.5, height: 5),

                                  Padding(
                                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                                    child: TextButton.icon(
                                      onPressed: (){
                                        getIt<CartBloc>().add(ForcefullySetModuleEvent(cartState.cartList[0].item!.moduleId!));
                                        Get.toNamed(
                                          RouteHelper.getStoreRoute(id: cartState.cartList[0].item!.storeId, page: 'item'),
                                          arguments: StoreScreen(store: Store(id: cartState.cartList[0].item!.storeId), fromModule: false),
                                        );
                                      },
                                      icon: Icon(Icons.add_circle_outline_sharp, color: Theme.of(context).primaryColor),
                                      label: Text('add_more_items'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault)),
                                    ),
                                  ),
                                  !ResponsiveHelper.isDesktop(context) ? suggestedItemView(cartState.cartList) : const SizedBox(),

                                ]),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              !ResponsiveHelper.isDesktop(context) ? pricingView(cartState, cartState.cartList[0].item!) : const SizedBox(),

                            ]),
                          ),
                          ResponsiveHelper.isDesktop(context) ? const SizedBox(width: Dimensions.paddingSizeSmall) : const SizedBox(),

                          ResponsiveHelper.isDesktop(context) ? Expanded(flex: 4, child: pricingView(cartState, cartState.cartList[0].item!)) : const SizedBox(),
                        ],
                      ),

                      ResponsiveHelper.isDesktop(context) ? WebSuggestedItemViewWidget(cartList: cartState.cartList) : const SizedBox(),
                    ]),
                  ),
                ),
              ),
            ),

            ResponsiveHelper.isDesktop(context) ? const SizedBox.shrink() : CheckoutButton(cartState: cartState, availableList: cartState.availableList),
          ],
        ) : const NoDataScreen(isCart: true, text: '', showFooter: true);
      },
      ),
    );
  }

  Widget pricingView(CartState cartState, Item item){
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular( ResponsiveHelper.isDesktop(context) ? Dimensions.radiusDefault : Dimensions.radiusSmall),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ),
      child: GetBuilder<StoreController>(
        builder: (storeController) {
          return Column(children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                child: Text('order_summary'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),
            ),

            !ResponsiveHelper.isDesktop(context) && Get.find<SplashController>().getModuleConfig(item.moduleType).newVariation!
            && (storeController.store != null && storeController.store!.cutlery!) ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Image.asset(Images.cutlery, height: 18, width: 18),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('add_cutlery'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Text('do_not_have_cutlery'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                  ]),
                ),

                Transform.scale(
                  scale: 0.7,
                  child: CupertinoSwitch(
                    value: cartState.addCutlery,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (bool? value) {
                      getIt<CartBloc>().add(const UpdateCutleryEvent(true));
                    },
                    trackColor: Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                )

              ]),
            ) : const SizedBox(),

            ResponsiveHelper.isDesktop(context) ? const SizedBox() : Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              margin: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall) : EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: (){
                      if(ResponsiveHelper.isDesktop(context)){
                        Get.dialog(const Dialog(child: NotAvailableBottomSheetWidget()));
                      }else{
                        showModalBottomSheet(
                          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                          builder: (con) => const NotAvailableBottomSheetWidget(),
                        );
                      }
                    },
                    child: Row(children: [
                      Expanded(child: Text('if_any_product_is_not_available'.tr, style: robotoMedium, maxLines: 2, overflow: TextOverflow.ellipsis)),
                      const Icon(Icons.arrow_forward_ios_sharp, size: 18),
                    ]),
                  ),

                  cartState.notAvailableIndex != -1 ? Row(children: [
                    Text(cartState.notAvailableList[cartState.notAvailableIndex].tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),

                    IconButton(
                      onPressed: ()=> getIt<CartBloc>().add(SetAvailableIndexEvent(-1, true)),
                      icon: const Icon(Icons.clear, size: 18),
                    )
                  ]) : const SizedBox(),
                ],
              ),
            ),
            ResponsiveHelper.isDesktop(context) ? const SizedBox() : const SizedBox(height: Dimensions.paddingSizeSmall),

            // Total
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('item_price'.tr, style: robotoRegular),
                  PriceConverter.convertAnimationPrice(cartState.itemPrice, textStyle: robotoRegular),
                ]),
                SizedBox(height: cartState.variationPrice > 0 ? Dimensions.paddingSizeSmall : 0),

                Get.find<SplashController>().getModuleConfig(item.moduleType).newVariation! && cartState.variationPrice > 0 ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('variations'.tr, style: robotoRegular),
                    Text('(+) ${PriceConverter.convertPrice(cartState.variationPrice)}', style: robotoRegular, textDirection: TextDirection.ltr),
                  ],
                ) : const SizedBox(),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('discount'.tr, style: robotoRegular),
                  storeController.store != null ? Row(children: [
                    Text('(-)', style: robotoRegular),
                    PriceConverter.convertAnimationPrice(cartState.itemDiscountPrice, textStyle: robotoRegular),
                  ]) : Text('calculating'.tr, style: robotoRegular),
                  // Text('(-) ${PriceConverter.convertPrice(cartState.itemDiscountPrice)}', style: robotoRegular, textDirection: TextDirection.ltr),
                ]),
                SizedBox(height: Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? 10 : 0),

                Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('addons'.tr, style: robotoRegular),
                    Text('(+) ${PriceConverter.convertPrice(cartState.addOns)}', style: robotoRegular, textDirection: TextDirection.ltr),
                  ],
                ) : const SizedBox(),
              ]),
            ),



            ResponsiveHelper.isDesktop(context) ? CheckoutButton(cartState: cartState, availableList: cartState.availableList) : const SizedBox.shrink(),

          ]);
        }
      ),
    );
  }

  Widget suggestedItemView(List<Cart> cartList){
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      width: double.infinity,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        GetBuilder<StoreController>(builder: (storeController) {
          List<Item>? suggestedItems;
          if(storeController.cartSuggestItemModel != null){
            suggestedItems = [];
            List<int> cartIds = [];
            for (Cart cartItem in cartList) {
              cartIds.add(cartItem.item!.id!);
            }
            for (Item item in storeController.cartSuggestItemModel!.items!) {
              if(!cartIds.contains(item.id)){
                suggestedItems.add(item);
              }
            }
          }
          return storeController.cartSuggestItemModel != null && suggestedItems!.isNotEmpty ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                child: Text('you_may_also_like'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
              ),

              SizedBox(
                height: ResponsiveHelper.isDesktop(context) ? 160 : 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: suggestedItems.length,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(left: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeDefault),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: 20) : const EdgeInsets.symmetric(vertical: 10) ,
                      child: Container(
                        width: ResponsiveHelper.isDesktop(context) ? 500 : 300,
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeExtraSmall),
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        child: ItemWidget(
                          isStore: false, item: suggestedItems![index], fromCartSuggestion: true,
                          store: null, index: index, length: null, isCampaign: false, inStore: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ) : const SizedBox();
        }),
      ]),
    );
  }

}

class CheckoutButton extends StatelessWidget {
  final CartState cartState;
  final List<bool> availableList;
  const CheckoutButton({super.key, required this.cartState, required this.availableList});

  @override
  Widget build(BuildContext context) {
    double percentage = 0;

    return Container(
      width: Dimensions.webMaxWidth,
      padding:  const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusDefault : 0),
        boxShadow: ResponsiveHelper.isDesktop(context) ? null : [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.2), blurRadius: 10)]
      ),
      child: GetBuilder<StoreController>(
        builder: (storeController) {
          if(Get.find<StoreController>().store != null && !Get.find<StoreController>().store!.freeDelivery! && Get.find<SplashController>().configModel!.freeDeliveryOver != null){
            percentage = cartState.subTotal/Get.find<SplashController>().configModel!.freeDeliveryOver!;
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              (storeController.store != null && !storeController.store!.freeDelivery! && Get.find<SplashController>().configModel!.freeDeliveryOver != null && percentage < 1)
              ? Column(children: [
                  Row(children: [
                    Image.asset(Images.percentTag, height: 20, width: 20),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text(
                      PriceConverter.convertPrice(Get.find<SplashController>().configModel!.freeDeliveryOver! - cartState.subTotal),
                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor), textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text('more_for_free_delivery'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                  ]),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                LinearProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  value: percentage,
                ),
              ]) : const SizedBox(),

              ResponsiveHelper.isDesktop(context) ? const Divider(height: 1) : const SizedBox(),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('subtotal'.tr, style: robotoMedium.copyWith(color:  ResponsiveHelper.isDesktop(context) ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).primaryColor)),
                    PriceConverter.convertAnimationPrice(cartState.subTotal, textStyle: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
                    // Text(
                    //   PriceConverter.convertPrice(cartState.subTotal),
                    //   style: robotoMedium.copyWith(color: ResponsiveHelper.isDesktop(context) ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).primaryColor), textDirection: TextDirection.ltr,
                    // ),
                  ],
                ),
              ),

              ResponsiveHelper.isDesktop(context) && Get.find<SplashController>().getModuleConfig(cartState.cartList[0].item!.moduleType).newVariation!
              && (storeController.store != null && storeController.store!.cutlery!) ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Image.asset(Images.cutlery, height: 18, width: 18),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('add_cutlery'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Text('do_not_have_cutlery'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                    ]),
                  ),

                  Transform.scale(
                    scale: 0.7,
                    child: CupertinoSwitch(
                      value: cartState.addCutlery,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (bool? value) {
                        getIt<CartBloc>().add(const UpdateCutleryEvent(true));
                      },
                      trackColor: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                  )
                ]),
              ) : const SizedBox(),
              ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

              !ResponsiveHelper.isDesktop(context) ? const SizedBox() :
              Container(
                width: Dimensions.webMaxWidth,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: Theme.of(context).primaryColor, width: 0.5)),
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                //margin: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall) : EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: (){
                        if(ResponsiveHelper.isDesktop(context)){
                          Get.dialog(const Dialog(child: NotAvailableBottomSheetWidget()));
                        }else{
                          showModalBottomSheet(
                            context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                            builder: (con) => const NotAvailableBottomSheetWidget(),
                          );
                        }
                      },
                      child: Row(children: [
                        Expanded(child: Text('if_any_product_is_not_available'.tr, style: robotoMedium, maxLines: 2, overflow: TextOverflow.ellipsis)),
                        const Icon(Icons.keyboard_arrow_down, size: 18),
                      ]),
                    ),

                    cartState.notAvailableIndex != -1 ? Row(children: [
                      Text(cartState.notAvailableList[cartState.notAvailableIndex].tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),

                      IconButton(
                        onPressed: ()=> getIt<CartBloc>().add(SetAvailableIndexEvent(-1, true)),
                        icon: const Icon(Icons.clear, size: 18),
                      )
                    ]) : const SizedBox(),
                  ],
                ),
              ),
              ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

              SafeArea(
                child: CustomButton(
                  buttonText: 'proceed_to_checkout'.tr,
                  fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeSmall : Dimensions.fontSizeLarge,
                  isBold:  ResponsiveHelper.isDesktop(context) ? false : true,
                  radius: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusSmall : Dimensions.radiusDefault,
                  onPressed: () {
                  if(!cartState.cartList.first.item!.scheduleOrder! && availableList.contains(false)) {
                    showCustomSnackBar('one_or_more_product_unavailable'.tr);
                  } /*else if(AuthHelper.isGuestLoggedIn() && !Get.find<SplashController>().configModel!.guestCheckoutStatus!) {
                    showCustomSnackBar('currently_your_zone_have_no_permission_to_place_any_order'.tr);
                  }*/ else {
                    if(Get.find<SplashController>().module == null) {
                      int i = 0;
                      for(i = 0; i < Get.find<SplashController>().moduleList!.length; i++){
                        if(cartState.cartList[0].item!.moduleId == Get.find<SplashController>().moduleList![i].id){
                          break;
                        }
                      }
                      Get.find<SplashController>().setModule(Get.find<SplashController>().moduleList![i]);
                      HomeScreen.loadData(true);
                    }
                    Get.find<CouponController>().removeCouponData(false);

                    Get.toNamed(RouteHelper.getCheckoutRoute('cart'));
                  }
                }),
              ),
            ],
          );
        }
      ),
    );
  }
}
