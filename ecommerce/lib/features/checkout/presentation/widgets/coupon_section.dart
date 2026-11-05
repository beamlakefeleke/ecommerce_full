import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/coupon/presentation/bloc/coupon_bloc.dart';
import 'package:ecommerce/features/language/controllers/language_controller.dart';
import 'package:ecommerce/features/store/controllers/store_controller.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:ecommerce/features/checkout/presentation/widgets/checkout_balance_helper.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/features/checkout/presentation/widgets/coupon_bottom_sheet.dart';

class CouponSection extends StatelessWidget {
  final int? storeId;
  final TextEditingController couponTextController;
  final double total;
  final double price;
  final double discount;
  final double addOns;
  final double deliveryCharge;
  const CouponSection({
    super.key,
    this.storeId,
    required this.couponTextController,
    required this.total,
    required this.price,
    required this.discount,
    required this.addOns,
    required this.deliveryCharge,
  });

  void _applyCoupon(BuildContext context) {
    final couponBloc = context.read<CouponBloc>();
    if (couponTextController.text.isEmpty) {
      showCustomSnackBar('enter_a_coupon_code'.tr);
      return;
    }
    if (couponBloc.state.discount! < 1 && !couponBloc.state.freeDelivery) {
      if (!couponBloc.state.isLoading) {
        couponBloc.add(
          CouponApplied(
            couponCode: couponTextController.text,
            order: (price - discount) + addOns,
            deliveryCharge: deliveryCharge,
            storeId: Get.find<StoreController>().store!.id,
          ),
        );
      }
    } else {
      final double totalPrice = total + couponBloc.state.discount!;
      couponBloc.add(const CouponDataRemoved());
      couponTextController.text = '';
      final CheckoutState checkoutController = context
          .read<CheckoutBloc>()
          .state;
      if (checkoutController.isPartialPay ||
          checkoutController.paymentMethodIndex == 1) {
        checkoutCheckBalanceStatus(context, totalPrice, 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return storeId == null
        ? BlocConsumer<CouponBloc, CouponState>(
            listenWhen: (prev, curr) =>
                prev.discount != curr.discount ||
                prev.freeDelivery != curr.freeDelivery ||
                prev.message != curr.message,
            listener: (context, couponState) {
              if (couponState.message != null) {
                showCustomSnackBar(
                  couponState.message,
                  isError: couponState.messageIsError,
                );
              }
              final CheckoutState checkoutController = context
                  .read<CheckoutBloc>()
                  .state;
              if (couponState.discount! > 0) {
                couponTextController.text = 'coupon_applied'.tr;
                showCustomSnackBar(
                  '${'you_got_discount_of'.tr} ${PriceConverter.convertPrice(couponState.discount)}',
                  isError: false,
                );
                if (checkoutController.isPartialPay ||
                    checkoutController.paymentMethodIndex == 1) {
                  checkoutCheckBalanceStatus(
                    context,
                    total - couponState.discount!,
                    couponState.discount!,
                  );
                }
              }
            },
            builder: (context, couponController) {
              return Container(
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
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('promo_code'.tr, style: robotoMedium),
                        InkWell(
                          onTap: () {
                            if (ResponsiveHelper.isDesktop(context)) {
                              Get.dialog(
                                Dialog(
                                  child: CouponBottomSheet(
                                    storeId:
                                        Get.find<StoreController>().store!.id,
                                  ),
                                ),
                              ).then((value) {
                                if (value != null) {
                                  couponTextController.text = value.toString();
                                }
                              });
                            } else {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (con) => CouponBottomSheet(
                                  storeId:
                                      Get.find<StoreController>().store!.id,
                                ),
                              ).then((value) async {
                                if (value != null) {
                                  couponTextController.text = value.toString();
                                  if (couponTextController.text.isNotEmpty) {
                                    _applyCoupon(context);
                                  }
                                }
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Text(
                                  'add_voucher'.tr,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall,
                                ),
                                Icon(
                                  Icons.add,
                                  size: 20,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusDefault,
                        ),
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 0.2,
                        ),
                      ),
                      padding: const EdgeInsets.only(left: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: TextField(
                                controller: couponTextController,
                                style: robotoRegular.copyWith(
                                  height: ResponsiveHelper.isMobile(context)
                                      ? null
                                      : 2,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'enter_promo_code'.tr,
                                  hintStyle: robotoRegular.copyWith(
                                    color: Theme.of(context).hintColor,
                                  ),
                                  isDense: true,
                                  filled: true,
                                  enabled: couponController.discount == 0,
                                  fillColor: Theme.of(context).cardColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(
                                        Get.find<LocalizationController>().isLtr
                                            ? 10
                                            : 0,
                                      ),
                                      right: Radius.circular(
                                        Get.find<LocalizationController>().isLtr
                                            ? 0
                                            : 10,
                                      ),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Image.asset(
                                      Images.couponIcon,
                                      height: 10,
                                      width: 20,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _applyCoupon(context),
                            child: Container(
                              height: 45,
                              width:
                                  (couponController.discount! <= 0 &&
                                      !couponController.freeDelivery)
                                  ? 100
                                  : 50,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.all(
                                Dimensions.paddingSizeExtraSmall,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (couponController.discount! <= 0 &&
                                        !couponController.freeDelivery)
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault,
                                ),
                              ),
                              child:
                                  (couponController.discount! <= 0 &&
                                      !couponController.freeDelivery)
                                  ? !couponController.isLoading
                                        ? Text(
                                            'apply'.tr,
                                            style: robotoMedium.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).cardColor,
                                            ),
                                          )
                                        : const SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                  : Icon(
                                      Icons.clear,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                ),
              );
            },
          )
        : const SizedBox();
  }
}
