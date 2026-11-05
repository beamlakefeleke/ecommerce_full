import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/features/cart/data/models/cart_model.dart';
import 'package:ecommerce/common/models/config_model.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_dropdown.dart';
import 'package:ecommerce/features/cart/presentation/widgets/delivery_option_button_widget.dart';
import 'package:ecommerce/features/checkout/presentation/widgets/coupon_section.dart';
import 'package:ecommerce/features/checkout/presentation/widgets/delivery_instruction_view.dart';
import 'package:ecommerce/features/checkout/presentation/widgets/delivery_section.dart';
import 'package:ecommerce/features/checkout/presentation/widgets/deliveryman_tips_section.dart';
import 'package:ecommerce/features/checkout/presentation/widgets/partial_pay_view.dart';
import 'package:ecommerce/features/checkout/presentation/widgets/payment_section.dart';
import 'package:ecommerce/features/checkout/presentation/widgets/time_slot_section.dart';
import 'package:ecommerce/features/checkout/presentation/widgets/web_delivery_instruction_view.dart';
import 'package:ecommerce/features/store/widgets/camera_button_sheet_widget.dart';
import 'dart:io';

class TopSection extends StatelessWidget {
  final CheckoutState checkoutController;
  final TextEditingController couponTextController;
  final TextEditingController noteController;
  final TextEditingController tipController;
  final TextEditingController streetNumberController;
  final TextEditingController houseController;
  final TextEditingController floorController;
  final FocusNode streetNode;
  final FocusNode houseNode;
  final FocusNode floorNode;
  final double charge;
  final double deliveryCharge;
  final List<DropdownItem<int>> addressList;
  final bool tomorrowClosed;
  final bool todayClosed;
  final Module? module;
  final double price;
  final double discount;
  final double addOns;
  final int? storeId;
  final List<AddressModel> address;
  final List<CartModel?>? cartList;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final double total;
  final bool isOfflinePaymentActive;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  final JustTheController tooltipController1;
  final JustTheController tooltipController2;
  final JustTheController dmTipsTooltipController;

  const TopSection({
    super.key,
    required this.deliveryCharge,
    required this.charge,
    required this.tomorrowClosed,
    required this.todayClosed,
    required this.price,
    required this.discount,
    required this.addOns,
    required this.addressList,
    required this.checkoutController,
    required this.couponTextController,
    required this.noteController,
    required this.tipController,
    required this.streetNumberController,
    required this.houseController,
    required this.floorController,
    required this.streetNode,
    required this.houseNode,
    required this.floorNode,
    this.module,
    this.storeId,
    required this.address,
    required this.cartList,
    required this.isCashOnDeliveryActive,
    required this.isDigitalPaymentActive,
    required this.isWalletActive,
    required this.total,
    required this.isOfflinePaymentActive,
    required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController,
    required this.guestNumberNode,
    required this.guestEmailController,
    required this.guestEmailNode,
    required this.tooltipController1,
    required this.tooltipController2,
    required this.dmTipsTooltipController,
  });

  @override
  Widget build(BuildContext context) {
    bool takeAway = (checkoutController.orderType == 'take_away');
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();

    return Container(
      decoration: ResponsiveHelper.isDesktop(context)
          ? BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            )
          : null,
      child: Column(
        children: [
          storeId != null
              ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('your_prescription'.tr, style: robotoMedium),
                          const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall,
                          ),

                          JustTheTooltip(
                            backgroundColor: Colors.black87,
                            controller: tooltipController1,
                            preferredDirection: AxisDirection.right,
                            tailLength: 14,
                            tailBaseWidth: 20,
                            content: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'prescription_tool_tip'.tr,
                                style: robotoRegular.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            child: InkWell(
                              onTap: () => tooltipController1.showTooltip(),
                              child: const Icon(Icons.info_outline),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount:
                              checkoutController.pickedPrescriptions.length + 1,
                          itemBuilder: (context, index) {
                            XFile? file =
                                index ==
                                    checkoutController
                                        .pickedPrescriptions
                                        .length
                                ? null
                                : checkoutController.pickedPrescriptions[index];
                            if (index < 5 &&
                                index ==
                                    checkoutController
                                        .pickedPrescriptions
                                        .length) {
                              return InkWell(
                                onTap: () {
                                  if (ResponsiveHelper.isDesktop(context)) {
                                    context.read<CheckoutBloc>().add(
                                      const CheckoutPrescriptionImagePicked(
                                        isRemove: false,
                                        isCamera: false,
                                      ),
                                    );
                                  } else {
                                    Get.bottomSheet(
                                      const CameraButtonSheetWidget(),
                                    );
                                  }
                                },
                                child: DottedBorder(
                                  color: Theme.of(context).primaryColor,
                                  strokeWidth: 1,
                                  strokeCap: StrokeCap.butt,
                                  dashPattern: const [5, 5],
                                  padding: const EdgeInsets.all(0),
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(
                                    Dimensions.radiusDefault,
                                  ),
                                  child: Container(
                                    height: 98,
                                    width: 98,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.cloud_upload,
                                          color: Theme.of(
                                            context,
                                          ).disabledColor,
                                          size: 32,
                                        ),
                                        Text(
                                          'upload_your_prescription'.tr,
                                          style: robotoRegular.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).disabledColor,
                                            fontSize: Dimensions.fontSizeSmall,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                            return file != null
                                ? Container(
                                    margin: const EdgeInsets.only(
                                      right: Dimensions.paddingSizeSmall,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall,
                                      ),
                                    ),
                                    child: DottedBorder(
                                      color: Theme.of(context).primaryColor,
                                      strokeWidth: 1,
                                      strokeCap: StrokeCap.butt,
                                      dashPattern: const [5, 5],
                                      padding: const EdgeInsets.all(0),
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(
                                        Dimensions.radiusDefault,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimensions.radiusDefault,
                                                  ),
                                              child: GetPlatform.isWeb
                                                  ? Image.network(
                                                      file.path,
                                                      width: 98,
                                                      height: 98,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.file(
                                                      File(file.path),
                                                      width: 98,
                                                      height: 98,
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: InkWell(
                                                onTap: () => context
                                                    .read<CheckoutBloc>()
                                                    .add(
                                                      CheckoutPrescriptionImageRemoved(
                                                        index,
                                                      ),
                                                    ),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(
                                                    Dimensions.paddingSizeSmall,
                                                  ),
                                                  child: Icon(
                                                    Icons.delete_forever,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox();
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // delivery option
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
              vertical: Dimensions.paddingSizeSmall,
            ),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('delivery_type'.tr, style: robotoMedium),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                storeId != null
                    ? DeliveryOptionButtonWidget(
                        value: 'delivery',
                        title: 'home_delivery'.tr,
                        charge: charge,
                        isFree: checkoutController.store!.freeDelivery,
                        fromWeb: true,
                        total: total,
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Get.find<SplashController>()
                                            .configModel!
                                            .homeDeliveryStatus ==
                                        1 &&
                                    checkoutController.store!.delivery!
                                ? DeliveryOptionButtonWidget(
                                    value: 'delivery',
                                    title: 'home_delivery'.tr,
                                    charge: charge,
                                    isFree:
                                        checkoutController.store!.freeDelivery,
                                    fromWeb: true,
                                    total: total,
                                  )
                                : const SizedBox(),
                            const SizedBox(
                              width: Dimensions.paddingSizeDefault,
                            ),

                            Get.find<SplashController>()
                                            .configModel!
                                            .takeawayStatus ==
                                        1 &&
                                    checkoutController.store!.takeAway!
                                ? DeliveryOptionButtonWidget(
                                    value: 'take_away',
                                    title: 'take_away'.tr,
                                    charge: deliveryCharge,
                                    isFree: true,
                                    fromWeb: true,
                                    total: total,
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          ///Delivery_fee
          !takeAway && !isGuestLoggedIn
              ? Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${'delivery_charge'.tr}: '),
                      Text(
                        checkoutController.store!.freeDelivery!
                            ? 'free'.tr
                            : checkoutController.distance != -1
                            ? PriceConverter.convertPrice(charge)
                            : 'calculating'.tr,
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
          SizedBox(
            height: !takeAway && !isGuestLoggedIn
                ? Dimensions.paddingSizeLarge
                : 0,
          ),

          ///delivery section
          DeliverySection(
            checkoutController: checkoutController,
            address: address,
            addressList: addressList,
            guestNameTextEditingController: guestNameTextEditingController,
            guestNumberTextEditingController: guestNumberTextEditingController,
            guestNumberNode: guestNumberNode,
            guestEmailController: guestEmailController,
            guestEmailNode: guestEmailNode,
            streetNumberController: streetNumberController,
            houseController: houseController,
            floorController: floorController,
            streetNode: streetNode,
            houseNode: houseNode,
            floorNode: floorNode,
          ),

          SizedBox(
            height: !takeAway
                ? isDesktop
                      ? Dimensions.paddingSizeLarge
                      : Dimensions.paddingSizeSmall
                : 0,
          ),

          ///delivery instruction
          !takeAway
              ? isDesktop
                    ? const WebDeliveryInstructionView()
                    : const DeliveryInstructionView()
              : const SizedBox(),

          SizedBox(height: !takeAway ? Dimensions.paddingSizeSmall : 0),

          /// Time Slot
          TimeSlotSection(
            storeId: storeId,
            checkoutController: checkoutController,
            cartList: cartList,
            tooltipController2: tooltipController2,
            tomorrowClosed: tomorrowClosed,
            todayClosed: todayClosed,
            module: module,
          ),

          /// Coupon..
          !isDesktop && !isGuestLoggedIn
              ? CouponSection(
                  storeId: storeId,
                  couponTextController: couponTextController,
                  total: total,
                  price: price,
                  discount: discount,
                  addOns: addOns,
                  deliveryCharge: deliveryCharge,
                )
              : const SizedBox(),

          ///DmTips..
          DeliveryManTipsSection(
            takeAway: takeAway,
            tooltipController3: dmTipsTooltipController,
            totalPrice: total,
            onTotalChange: (double price) => total + price,
            tipController: tipController,
            storeId: storeId,
          ),

          ///Payment..
          Container(
            decoration: isDesktop
                ? const BoxDecoration()
                : BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeLarge,
              horizontal: Dimensions.paddingSizeLarge,
            ),
            child: Column(
              children: [
                PaymentSection(
                  storeId: storeId,
                  isCashOnDeliveryActive: isCashOnDeliveryActive,
                  isDigitalPaymentActive: isDigitalPaymentActive,
                  isWalletActive: isWalletActive,
                  total: total,
                  isOfflinePaymentActive: isOfflinePaymentActive,
                ),
                SizedBox(
                  height: isGuestLoggedIn ? 0 : Dimensions.paddingSizeLarge,
                ),

                !isDesktop && !isGuestLoggedIn
                    ? PartialPayView(
                        totalPrice: total,
                        isPrescription: storeId != null,
                      )
                    : const SizedBox(),
              ],
            ),
          ),
          SizedBox(height: isDesktop ? Dimensions.paddingSizeLarge : 0),
        ],
      ),
    );
  }
}
