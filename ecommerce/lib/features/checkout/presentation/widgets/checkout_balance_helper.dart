import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/profile/controllers/profile_controller.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:ecommerce/features/checkout/presentation/widgets/partial_pay_dialog_widget.dart';

/// Port of the legacy `CheckoutController.checkBalanceStatus`: resets partial
/// pay + payment method and opens the partial-pay decision dialog based on the
/// user's wallet balance vs. the amount due.
void checkoutCheckBalanceStatus(
  BuildContext context,
  double totalPrice,
  double discount,
) {
  final bloc = context.read<CheckoutBloc>();
  final double amount = totalPrice - discount;
  if (bloc.state.isPartialPay) {
    bloc.add(const CheckoutPartialPaymentToggled());
  }
  bloc.add(const CheckoutPaymentMethodSet(-1));

  final double walletBalance =
      Get.find<ProfileController>().userInfoModel!.walletBalance!;
  Get.dialog(
    PartialPayDialogWidget(
      isPartialPay: walletBalance < amount && walletBalance != 0.0,
      totalPrice: amount,
    ),
    useSafeArea: false,
  );
}
