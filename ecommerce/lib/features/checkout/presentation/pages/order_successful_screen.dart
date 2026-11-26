import 'dart:async';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/common/controllers/theme_controller.dart';
import 'package:ecommerce/features/location/domain/models/zone_response_model.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce/helper/address_helper.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/common/widgets/web_menu_bar.dart';
import 'package:ecommerce/features/checkout/presentation/widgets/payment_failed_dialog.dart';
import 'package:ecommerce/features/order/presentation/bloc/order_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class OrderSuccessfulScreen extends StatefulWidget {
  final String? orderID;
  final String? contactPersonNumber;
  const OrderSuccessfulScreen({
    super.key,
    required this.orderID,
    this.contactPersonNumber,
  });

  @override
  State<OrderSuccessfulScreen> createState() => _OrderSuccessfulScreenState();
}

class _OrderSuccessfulScreenState extends State<OrderSuccessfulScreen> {
  bool? _isCashOnDeliveryActive = false;
  String? orderId;

  @override
  void initState() {
    super.initState();

    orderId = widget.orderID!;
    if (widget.orderID != null) {
      if (widget.orderID!.contains('?')) {
        var parts = widget.orderID!.split('?');
        String id = parts[0].trim(); // prefix: "date"
        orderId = id;
      }
    }

    context.read<OrderBloc>().add(
      OrderTrackRequested(
        orderId: orderId.toString(),
        order: null,
        fromTracking: false,
        contactNumber: widget.contactPersonNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (value) async {
        await Get.offAllNamed(RouteHelper.getInitialRoute());
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            double total = 0;
            bool success = true;
            bool parcel = false;
            double? maximumCodOrderAmount;
            if (state.trackModel != null) {
              total =
                  ((state.trackModel!.orderAmount! / 100) *
                  getIt<SplashBloc>()
                      .state
                      .configModel!
                      .loyaltyPointItemPurchasePoint!);
              success =
                  state.trackModel!.paymentStatus == 'paid' ||
                  state.trackModel!.paymentMethod == 'cash_on_delivery' ||
                  state.trackModel!.paymentMethod == 'partial_payment';
              parcel = state.trackModel!.paymentMethod == 'parcel';
              for (ZoneData zData
                  in AddressHelper.getUserAddressFromSharedPref()!.zoneData!) {
                for (Modules m in zData.modules!) {
                  if (m.id == getIt<SplashBloc>().state.module!.id) {
                    maximumCodOrderAmount = m.pivot!.maximumCodOrderAmount;
                    break;
                  }
                }
                if (zData.id ==
                    AddressHelper.getUserAddressFromSharedPref()!.zoneId) {
                  _isCashOnDeliveryActive = zData.cashOnDelivery;
                }
              }

              if (!success &&
                  !Get.isDialogOpen! &&
                  state.trackModel!.orderStatus != 'canceled' &&
                  Get.currentRoute.startsWith(RouteHelper.orderSuccess)) {
                Future.delayed(const Duration(seconds: 1), () {
                  Get.dialog(
                    PaymentFailedDialog(
                      orderID: orderId,
                      isCashOnDelivery: _isCashOnDeliveryActive,
                      orderAmount: total,
                      maxCodOrderAmount: maximumCodOrderAmount,
                      orderType: parcel ? 'parcel' : 'delivery',
                    ),
                    barrierDismissible: false,
                  );
                });
              }
            }

            return state.trackModel != null
                ? Center(
                    child: SingleChildScrollView(
                      child: FooterView(
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                success ? Images.checked : Images.warning,
                                width: 100,
                                height: 100,
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeLarge,
                              ),

                              Text(
                                success
                                    ? parcel
                                          ? 'you_placed_the_parcel_request_successfully'
                                                .tr
                                          : 'you_placed_the_order_successfully'
                                                .tr
                                    : 'your_order_is_failed_to_place'.tr,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),

                              AuthHelper.isGuestLoggedIn()
                                  ? SelectableText(
                                      '${'order_id'.tr}: $orderId',
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )
                                  : const SizedBox(),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeLarge,
                                  vertical: Dimensions.paddingSizeSmall,
                                ),
                                child: Text(
                                  success
                                      ? parcel
                                            ? 'your_parcel_request_is_placed_successfully'
                                                  .tr
                                            : 'your_order_is_placed_successfully'
                                                  .tr
                                      : 'your_order_is_failed_to_place_because'
                                            .tr,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              ResponsiveHelper.isDesktop(context) &&
                                      (success &&
                                          getIt<SplashBloc>()
                                                  .state
                                                  .configModel!
                                                  .loyaltyPointStatus ==
                                              1 &&
                                          total.floor() > 0) &&
                                      AuthHelper.isLoggedIn()
                                  ? Column(
                                      children: [
                                        Image.asset(
                                          Get.find<ThemeController>().darkTheme
                                              ? Images.congratulationDark
                                              : Images.congratulationLight,
                                          width: 150,
                                          height: 150,
                                        ),

                                        Text(
                                          'congratulations'.tr,
                                          style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeLarge,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: Dimensions.paddingSizeSmall,
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeLarge,
                                          ),
                                          child: Text(
                                            '${'you_have_earned'.tr} ${total.floor().toString()} ${'points_it_will_add_to'.tr}',
                                            style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeLarge,
                                              color: Theme.of(
                                                context,
                                              ).disabledColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                              const SizedBox(height: 30),

                              Padding(
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall,
                                ),
                                child: CustomButton(
                                  width: ResponsiveHelper.isDesktop(context)
                                      ? 300
                                      : double.infinity,
                                  buttonText: 'back_to_home'.tr,
                                  onPressed: () {
                                    getIt<AuthRepository>().saveEarningPoint(
                                      total.toStringAsFixed(0),
                                    );
                                    Get.offAllNamed(
                                      RouteHelper.getInitialRoute(),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
