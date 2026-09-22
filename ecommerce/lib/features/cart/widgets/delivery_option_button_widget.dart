import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:ecommerce/core/di/injection.dart';

class DeliveryOptionButtonWidget extends StatefulWidget {
  final String value;
  final String title;
  final double? charge;
  final bool? isFree;
  final bool fromWeb;
  final double total;
  const DeliveryOptionButtonWidget({super.key, required this.value, required this.title, required this.charge, required this.isFree,
    this.fromWeb = false, required this.total});

  @override
  State<DeliveryOptionButtonWidget> createState() => _DeliveryOptionButtonWidgetState();
}

class _DeliveryOptionButtonWidgetState extends State<DeliveryOptionButtonWidget> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 200), (){
      getIt<CheckoutBloc>().add(OrderTypeSet(type: Get.find<SplashController>().configModel!.homeDeliveryStatus == 1
          && getIt<CheckoutBloc>().state.store!.delivery! ? 'delivery' : 'take_away'));
    });
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, checkoutState) {
        bool select = checkoutState.orderType == widget.value;

        return InkWell(
          onTap: () {
            getIt<CheckoutBloc>().add(OrderTypeSet(type: widget.value));
            getIt<CheckoutBloc>().add(const InstructionSelected(index: -1));

            if(widget.value == 'take_away') {
              if(checkoutState.isPartialPay) {
                double tips = 0;
                try{
                  tips = double.parse(Get.find<CheckoutController>().tipController.text);
                } catch(_) {}
                Get.find<CheckoutController>().checkBalanceStatus(widget.total, widget.charge! + tips);
              }
            } else {
              if(checkoutState.isPartialPay){
                getIt<CheckoutBloc>().add(const PartialPaymentToggled());
              } else {
                getIt<CheckoutBloc>().add(const PaymentMethodSet(index: -1));
              }

            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: select  ? widget.fromWeb ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : Theme.of(context).cardColor : Colors.transparent,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(color: select ? Theme.of(context).primaryColor : Colors.transparent),
              boxShadow: [BoxShadow(color: select ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent, blurRadius: 10)]
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
            child: Row(
              children: [
                Radio(
                  value: widget.value,
                  groupValue: checkoutState.orderType,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (String? value) {
                    getIt<CheckoutBloc>().add(OrderTypeSet(type: value));
                  },
                  activeColor: Theme.of(context).primaryColor,
                  visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Text(widget.title, style: robotoMedium.copyWith(color: select ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color)),
                const SizedBox(width: 5),

              ],
            ),
          ),
        );
      },
    );
  }
}
