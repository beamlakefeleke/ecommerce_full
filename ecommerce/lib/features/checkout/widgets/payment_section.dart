import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/features/checkout/widgets/payment_method_bottom_sheet.dart';
class PaymentSection extends StatelessWidget {
  final int? storeId;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final double total;
  final bool isOfflinePaymentActive;  
  const PaymentSection({super.key, this.storeId, required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive,
    required this.isWalletActive, required this.total, required this.isOfflinePaymentActive,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(storeId != null ? 'payment_method'.tr : 'choose_payment_method'.tr, style: robotoMedium),

        storeId == null && !ResponsiveHelper.isDesktop(context) ? InkWell(
          onTap: (){
            Get.bottomSheet(
              BlocProvider.value(
                value: context.read<CheckoutBloc>(),
                child: PaymentMethodBottomSheet(
                  isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
                  isWalletActive: isWalletActive, storeId: storeId, totalPrice: total, isOfflinePaymentActive: isOfflinePaymentActive,
                ),
              ),
              backgroundColor: Colors.transparent, isScrollControlled: true,
            );

          },
          child: Image.asset(Images.paymentSelect, height: 24, width: 24),
        ) : const SizedBox(),
      ]),

      !ResponsiveHelper.isDesktop(context) ? const Divider() : const SizedBox(height: Dimensions.paddingSizeSmall),

      Container(
        decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.3), width: 1),
        ) : const BoxDecoration(),
        padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.radiusDefault) : EdgeInsets.zero,
        child: storeId != null ? state.paymentMethodIndex == 0 ? Row(children: [
          Image.asset(Images.cash , width: 20, height: 20,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Text('cash_on_delivery'.tr,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
          )),

          Text(
            PriceConverter.convertPrice(total), textDirection: TextDirection.ltr,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
          )

        ]) : const SizedBox() : InkWell(
          onTap: () {
            if(ResponsiveHelper.isDesktop(context) && state.paymentMethodIndex == -1){
              Get.dialog(Dialog(backgroundColor: Colors.transparent, child: BlocProvider.value(
                value: context.read<CheckoutBloc>(),
                child: PaymentMethodBottomSheet(
                  isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
                  isWalletActive: isWalletActive, storeId: storeId, totalPrice: total, isOfflinePaymentActive: isOfflinePaymentActive,
                )
              )));
            }
          },
          child: Row(children: [
            state.paymentMethodIndex != -1 ? Image.asset(
              state.paymentMethodIndex == 0 ? Images.cash
                  : state.paymentMethodIndex == 1 ? Images.wallet
                  : state.paymentMethodIndex == 2 ? Images.digitalPayment
                  : Images.cash,
              width: 20, height: 20,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ) : Icon(
              !ResponsiveHelper.isDesktop(context) ? Icons.wallet_outlined : Icons.add_circle_outline_sharp,
              size: 18, color: !ResponsiveHelper.isDesktop(context) ? Theme.of(context).disabledColor : Theme.of(context).primaryColor,
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            Expanded(
              child: Row(children: [
                Text(
                  state.paymentMethodIndex == 0 ? 'cash_on_delivery'.tr
                      : state.paymentMethodIndex == 1 ? 'wallet_payment'.tr
                      : state.paymentMethodIndex == 2 ? 'digital_payment'.tr
                      : state.paymentMethodIndex == 3 ? '${'offline_payment'.tr}(${state.offlineMethodList![state.selectedOfflineBankIndex].methodName})'
                      : !ResponsiveHelper.isDesktop(context) ? 'select_payment_method'.tr : 'add_payment_method'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: !ResponsiveHelper.isDesktop(context) ? Theme.of(context).disabledColor
                        : state.paymentMethodIndex == -1 ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                  ),
                ),

                state.paymentMethodIndex == -1 && !ResponsiveHelper.isDesktop(context) ? Padding(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                  child: Icon(Icons.error, size: 16, color: Theme.of(context).colorScheme.error),
                ) : const SizedBox(),
              ])
            ),
            state.paymentMethodIndex != -1 ? PriceConverter.convertAnimationPrice(
              state.viewTotalPrice,
              textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
            ) : const SizedBox(),
            // Text(
            //   PriceConverter.convertPrice(total), textDirection: TextDirection.ltr,
            //   style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
            // ),
            SizedBox(width: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0),

            storeId == null && ResponsiveHelper.isDesktop(context) ? InkWell(
              onTap: (){
                Get.dialog(Dialog(backgroundColor: Colors.transparent, child: BlocProvider.value(
                  value: context.read<CheckoutBloc>(),
                  child: PaymentMethodBottomSheet(
                    isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
                    isWalletActive: isWalletActive, storeId: storeId, totalPrice: total, isOfflinePaymentActive: isOfflinePaymentActive,
                  )
                )));
              },
              child: Image.asset(Images.paymentSelect, height: 24, width: 24),
            ) : const SizedBox(),
          ]),
        ),
      ),

    ]);
      }
    );
  }
}
