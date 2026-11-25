import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:ecommerce/features/checkout/presentation/widgets/checkout_balance_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeliveryOptionButtonWidget extends StatefulWidget {
  final String value;
  final String title;
  final double? charge;
  final bool? isFree;
  final bool fromWeb;
  final double total;
  const DeliveryOptionButtonWidget({
    super.key,
    required this.value,
    required this.title,
    required this.charge,
    required this.isFree,
    this.fromWeb = false,
    required this.total,
  });

  @override
  State<DeliveryOptionButtonWidget> createState() =>
      _DeliveryOptionButtonWidgetState();
}

class _DeliveryOptionButtonWidgetState
    extends State<DeliveryOptionButtonWidget> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      final checkoutBloc = context.read<CheckoutBloc>();
      checkoutBloc.add(
        CheckoutOrderTypeChanged(
          getIt<SplashBloc>().state.configModel!.homeDeliveryStatus == 1 &&
                  checkoutBloc.state.store!.delivery!
              ? 'delivery'
              : 'take_away',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, checkoutController) {
        bool select = checkoutController.orderType == widget.value;

        return InkWell(
          onTap: () {
            final checkoutBloc = context.read<CheckoutBloc>();
            checkoutBloc.add(CheckoutOrderTypeChanged(widget.value));
            checkoutBloc.add(const CheckoutInstructionSet(-1));

            if (widget.value == 'take_away') {
              if (checkoutController.isPartialPay) {
                checkoutCheckBalanceStatus(
                  context,
                  widget.total,
                  widget.charge! + checkoutController.tips,
                );
              }
            } else {
              if (checkoutController.isPartialPay) {
                checkoutBloc.add(const CheckoutPartialPaymentToggled());
              } else {
                checkoutBloc.add(const CheckoutPaymentMethodSet(-1));
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: select
                  ? widget.fromWeb
                        ? Theme.of(context).primaryColor.withOpacity(0.05)
                        : Theme.of(context).cardColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(
                color: select
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
              ),
              boxShadow: [
                BoxShadow(
                  color: select
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  blurRadius: 10,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
              vertical: Dimensions.paddingSizeExtraSmall,
            ),
            child: Row(
              children: [
                Radio(
                  value: widget.value,
                  groupValue: checkoutController.orderType,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (String? value) {
                    context.read<CheckoutBloc>().add(
                      CheckoutOrderTypeChanged(value),
                    );
                  },
                  activeColor: Theme.of(context).primaryColor,
                  visualDensity: const VisualDensity(
                    horizontal: -3,
                    vertical: -3,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Text(
                  widget.title,
                  style: robotoMedium.copyWith(
                    color: select
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ),
          ),
        );
      },
    );
  }
}
