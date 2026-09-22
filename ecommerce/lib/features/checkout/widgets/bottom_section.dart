import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/coupon/controllers/coupon_controller.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/profile/controllers/profile_controller.dart';
import 'package:ecommerce/common/models/config_model.dart';
import 'package:ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/features/checkout/widgets/condition_check_box.dart';
import 'package:ecommerce/features/checkout/widgets/coupon_section.dart';
import 'package:ecommerce/features/checkout/widgets/note_prescription_section.dart';
import 'package:ecommerce/features/checkout/widgets/partial_pay_view.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BottomSection extends StatelessWidget {
  final CheckoutController checkoutController;
  final double total;
  final Module module;
  final double subTotal;
  final double discount;
  final CouponController couponController;
  final bool taxIncluded;
  final double tax;
  final double deliveryCharge;
  final bool todayClosed;
  final bool tomorrowClosed;
  final double orderAmount;
  final double? maxCodOrderAmount;
  final int? storeId;
  final double? taxPercent;
  final double price;
  final double addOns;
  final Widget? checkoutButton;

  const BottomSection({
    super.key,
    required this.checkoutController,
    required this.total,
    required this.module,
    required this.subTotal,
    required this.discount,
    required this.couponController,
    required this.taxIncluded,
    required this.tax,
    required this.deliveryCharge,
    required this.todayClosed,
    required this.tomorrowClosed,
    required this.orderAmount,
    this.maxCodOrderAmount,
    this.storeId,
    this.taxPercent,
    required this.price,
    required this.addOns,
    this.checkoutButton,
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();

    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        bool takeAway = state.orderType == 'take_away';

        return Container(
          decoration: isDesktop
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
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Column(
            children: [
              isDesktop
                  ? pricingView(
                      context: context,
                      takeAway: takeAway,
                      state: state,
                    )
                  : const SizedBox(),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              /// Coupon
              isDesktop && !isGuestLoggedIn
                  ? CouponSection(
                      storeId: storeId,
                      couponController: checkoutController.couponController,
                      total: total,
                      price: price,
                      discount: discount,
                      addOns: addOns,
                      deliveryCharge: deliveryCharge,
                      onCheckBalanceStatus: (totalPrice, discount) {
                        if (state.isPartialPay) {
                          final walletBalance =
                              Get.find<ProfileController>()
                                  .userInfoModel
                                  ?.walletBalance ??
                              0;
                          if (totalPrice < walletBalance) {
                            context.read<CheckoutBloc>().add(
                              const PartialPaymentToggled(),
                            );
                            context.read<CheckoutBloc>().add(
                              const PaymentMethodSet(index: 1),
                            );
                          } else {
                            context.read<CheckoutBloc>().add(
                              const PaymentMethodSet(index: -1),
                            );
                          }
                        }
                      },
                    )
                  : const SizedBox(),

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
                  vertical: Dimensions.paddingSizeDefault,
                  horizontal: Dimensions.paddingSizeLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Additional Note & prescription
                    NoteAndPrescriptionSection(
                      noteController: checkoutController.noteController,
                      storeId: storeId,
                    ),

                    isDesktop && !isGuestLoggedIn
                        ? PartialPayView(
                            totalPrice: total,
                            isPrescription: storeId != null,
                          )
                        : const SizedBox(),

                    !isDesktop
                        ? pricingView(
                            context: context,
                            takeAway: takeAway,
                            state: state,
                          )
                        : const SizedBox(),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    const CheckoutCondition(),

                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    isDesktop
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'total_amount'.tr,
                                        style: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeLarge,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      storeId == null
                                          ? const SizedBox()
                                          : Text(
                                              'Once_your_order_is_confirmed_you_will_receive'
                                                  .tr,
                                              style: robotoRegular.copyWith(
                                                fontSize: Dimensions
                                                    .fontSizeOverSmall,
                                                color: Theme.of(
                                                  context,
                                                ).disabledColor,
                                              ),
                                            ),
                                    ],
                                  ),
                                  storeId == null
                                      ? const SizedBox()
                                      : Text(
                                          'a_notification_with_your_bill_total'
                                              .tr,
                                          style: robotoRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeOverSmall,
                                            color: Theme.of(
                                              context,
                                            ).disabledColor,
                                          ),
                                        ),
                                ],
                              ),
                              PriceConverter.convertAnimationPrice(
                                state.viewTotalPrice,
                                textStyle: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: state.isPartialPay
                                      ? Theme.of(
                                          context,
                                        ).textTheme.bodyMedium!.color
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ],
                ),
              ),

              isDesktop
                  ? Padding(
                      padding: const EdgeInsets.only(
                        top: Dimensions.paddingSizeLarge,
                      ),
                      child: checkoutButton,
                    )
                  : const SizedBox(),
            ],
          ),
        );
      },
    );
  }

  Widget pricingView({
    required BuildContext context,
    required bool takeAway,
    required CheckoutState state,
  }) {
    // Cached once instead of calling Get.find() repeatedly below.
    final configModel = Get.find<SplashController>().configModel;
    final dmTipsEnabled = !takeAway && (configModel?.dmTipsStatus == 1);
    final additionalChargeEnabled =
        configModel?.additionalChargeStatus ?? false;
    final showDeliveryFee =
        !(AuthHelper.isGuestLoggedIn() && state.guestAddress == null);

    return Column(
      children: [
        ResponsiveHelper.isDesktop(context)
            ? Align(
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
              )
            : const SizedBox(),

        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.isDesktop(context)
                ? Dimensions.paddingSizeLarge
                : 0,
          ),
          child: Column(
            children: [
              storeId == null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          module.addOn! ? 'subtotal'.tr : 'item_price'.tr,
                          style: robotoMedium,
                        ),
                        Text(
                          PriceConverter.convertPrice(subTotal),
                          style: robotoMedium,
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    )
                  : const SizedBox(),
              SizedBox(
                height: storeId == null ? Dimensions.paddingSizeSmall : 0,
              ),

              storeId == null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('discount'.tr, style: robotoRegular),
                        Text(
                          '(-) ${PriceConverter.convertPrice(discount)}',
                          style: robotoRegular,
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    )
                  : const SizedBox(),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              (couponController.discount! > 0 || couponController.freeDelivery)
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('coupon_discount'.tr, style: robotoRegular),
                            (couponController.coupon != null &&
                                    couponController.coupon!.couponType ==
                                        'free_delivery')
                                ? Text(
                                    'free_delivery'.tr,
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                : Text(
                                    '(-) ${PriceConverter.convertPrice(couponController.discount)}',
                                    style: robotoRegular,
                                    textDirection: TextDirection.ltr,
                                  ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                      ],
                    )
                  : const SizedBox(),

              storeId == null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${'vat_tax'.tr} ${taxIncluded ? 'tax_included'.tr : ''} (${taxPercent ?? 0}%)',
                          style: robotoRegular,
                        ),
                        Text(
                          (taxIncluded ? '' : '(+) ') +
                              PriceConverter.convertPrice(tax),
                          style: robotoRegular,
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    )
                  : const SizedBox(),
              SizedBox(
                height: storeId == null ? Dimensions.paddingSizeSmall : 0,
              ),

              dmTipsEnabled
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('delivery_man_tips'.tr, style: robotoRegular),
                        Text(
                          '(+) ${PriceConverter.convertPrice(state.tips)}',
                          style: robotoRegular,
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
              SizedBox(
                height: dmTipsEnabled ? Dimensions.paddingSizeSmall : 0.0,
              ),

              !showDeliveryFee
                  ? const SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('delivery_fee'.tr, style: robotoRegular),
                        state.distance == -1
                            ? Text(
                                'calculating'.tr,
                                style: robotoRegular.copyWith(
                                  color: Colors.red,
                                ),
                              )
                            : (deliveryCharge == 0 ||
                                  (couponController.coupon != null &&
                                      couponController.coupon!.couponType ==
                                          'free_delivery'))
                            ? Text(
                                'free'.tr,
                                style: robotoRegular.copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            : Text(
                                '(+) ${PriceConverter.convertPrice(deliveryCharge)}',
                                style: robotoRegular,
                                textDirection: TextDirection.ltr,
                              ),
                      ],
                    ),

              SizedBox(
                height: additionalChargeEnabled && showDeliveryFee
                    ? Dimensions.paddingSizeSmall
                    : 0,
              ),

              additionalChargeEnabled
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          configModel?.additionalChargeName ?? '',
                          style: robotoRegular,
                        ),
                        Text(
                          '(+) ${PriceConverter.convertPrice(configModel?.additionCharge ?? 0)}',
                          style: robotoRegular,
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    )
                  : const SizedBox(),
              SizedBox(
                height: state.isPartialPay ? Dimensions.paddingSizeSmall : 0,
              ),

              state.isPartialPay
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('paid_by_wallet'.tr, style: robotoRegular),
                        Text(
                          '(-) ${PriceConverter.convertPrice(Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0)}',
                          style: robotoRegular,
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    )
                  : const SizedBox(),
              SizedBox(
                height: state.isPartialPay ? Dimensions.paddingSizeSmall : 0,
              ),

              state.isPartialPay
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'due_payment'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: !ResponsiveHelper.isDesktop(context)
                                ? Theme.of(context).textTheme.bodyMedium!.color
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        PriceConverter.convertAnimationPrice(
                          state.viewTotalPrice,
                          textStyle: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: !ResponsiveHelper.isDesktop(context)
                                ? Theme.of(context).textTheme.bodyMedium!.color
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall,
                ),
                child: Divider(
                  thickness: 1,
                  color: Theme.of(context).hintColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
