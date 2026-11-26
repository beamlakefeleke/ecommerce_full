import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/order/presentation/bloc/order_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';

class PaymentFailedDialog extends StatelessWidget {
  final String? orderID;
  final String? orderType;
  final double? orderAmount;
  final double? maxCodOrderAmount;
  final bool? isCashOnDelivery;
  const PaymentFailedDialog({
    super.key,
    required this.orderID,
    required this.maxCodOrderAmount,
    required this.orderAmount,
    required this.orderType,
    required this.isCashOnDelivery,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Image.asset(Images.warning, width: 70, height: 70),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge,
                ),
                child: Text(
                  'are_you_agree_with_this_order_fail'.tr,
                  textAlign: TextAlign.center,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge,
                    color: Colors.red,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Text(
                  'if_you_do_not_pay'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              BlocListener<OrderBloc, OrderState>(
                listenWhen: (previous, current) =>
                    previous.actionStatus != current.actionStatus &&
                    (current.actionType == OrderActionType.switchToCod ||
                        current.actionType == OrderActionType.cancel),
                listener: (context, state) {
                  if (state.actionStatus != OrderActionStatus.success) {
                    if (state.actionStatus == OrderActionStatus.failure) {
                      showCustomSnackBar(state.actionMessage);
                    }
                    return;
                  }
                  if (state.actionType == OrderActionType.switchToCod) {
                    double total =
                        ((orderAmount! / 100) *
                        getIt<SplashBloc>()
                            .state
                            .configModel!
                            .loyaltyPointItemPurchasePoint!);
                    getIt<AuthRepository>().saveEarningPoint(
                      total.toStringAsFixed(0),
                    );
                  } else if (state.actionType == OrderActionType.cancel) {
                    Get.offAllNamed(RouteHelper.getInitialRoute());
                  }
                },
                child: BlocBuilder<OrderBloc, OrderState>(
                  builder: (context, state) {
                    return !state.isLoading
                        ? Column(
                            children: [
                              isCashOnDelivery!
                                  ? CustomButton(
                                      buttonText:
                                          'switch_to_cash_on_delivery'.tr,
                                      onPressed: () {
                                        if ((((maxCodOrderAmount != null &&
                                                        orderAmount! <
                                                            maxCodOrderAmount!) ||
                                                    maxCodOrderAmount == null ||
                                                    maxCodOrderAmount == 0) &&
                                                orderType != 'parcel') ||
                                            orderType == 'parcel') {
                                          context.read<OrderBloc>().add(
                                            OrderSwitchedToCod(orderID),
                                          );
                                        } else {
                                          if (Get.isDialogOpen!) {
                                            Get.back();
                                          }
                                          showCustomSnackBar(
                                            '${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}',
                                          );
                                        }
                                      },
                                      radius: Dimensions.radiusSmall,
                                      height: 40,
                                    )
                                  : const SizedBox(),
                              SizedBox(
                                height:
                                    getIt<SplashBloc>()
                                        .state
                                        .configModel!
                                        .cashOnDelivery!
                                    ? Dimensions.paddingSizeLarge
                                    : 0,
                              ),

                              TextButton(
                                onPressed: () {
                                  context.read<OrderBloc>().add(
                                    OrderCancelled(
                                      orderId: int.parse(orderID!),
                                      reason: 'Digital payment issue',
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).disabledColor.withOpacity(0.3),
                                  minimumSize: const Size(
                                    Dimensions.webMaxWidth,
                                    40,
                                  ),
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'cancel_order'.tr,
                                  textAlign: TextAlign.center,
                                  style: robotoBold.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge!.color,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
