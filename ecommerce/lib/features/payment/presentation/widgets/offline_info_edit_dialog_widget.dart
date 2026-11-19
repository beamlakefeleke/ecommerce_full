import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/order/domain/models/order_model.dart';
import 'package:ecommerce/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:ecommerce/features/payment/presentation/bloc/payment_event.dart';
import 'package:ecommerce/features/payment/presentation/bloc/payment_state.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/custom_text_field.dart';

class OfflineInfoEditDialogWidget extends StatelessWidget {
  final OfflinePayment offlinePayment;
  final int orderId;
  const OfflineInfoEditDialogWidget({
    super.key,
    required this.offlinePayment,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PaymentBloc>(),
      child: _OfflineInfoEditDialogView(
        offlinePayment: offlinePayment,
        orderId: orderId,
      ),
    );
  }
}

class _OfflineInfoEditDialogView extends StatefulWidget {
  final OfflinePayment offlinePayment;
  final int orderId;
  const _OfflineInfoEditDialogView({
    required this.offlinePayment,
    required this.orderId,
  });

  @override
  State<_OfflineInfoEditDialogView> createState() =>
      _OfflineInfoEditDialogViewState();
}

class _OfflineInfoEditDialogViewState
    extends State<_OfflineInfoEditDialogView> {
  /// Dynamic input controllers/focus nodes (rule 4: owned by the widget State).
  late final List<TextEditingController> _informationControllerList;
  late final List<FocusNode> _informationFocusList;

  @override
  void initState() {
    super.initState();
    _informationControllerList = [];
    _informationFocusList = [];
    for (int i = 0; i < widget.offlinePayment.input!.length; i++) {
      _informationControllerList.add(
        TextEditingController(text: widget.offlinePayment.input![i].userData),
      );
      _informationFocusList.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (final c in _informationControllerList) {
      c.dispose();
    }
    for (final f in _informationFocusList) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: BlocConsumer<PaymentBloc, PaymentState>(
            listenWhen: (p, c) => p.actionStatus != c.actionStatus,
            listener: (context, state) {
              if (state.actionStatus == OfflineInfoActionStatus.success) {
                Get.back();
              } else if (state.actionStatus ==
                  OfflineInfoActionStatus.failure) {
                showCustomSnackBar(state.errorMessage);
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset(Images.offlinePayment, height: 100),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Text(
                      'update_payment_info'.tr,
                      textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    ListView.builder(
                      itemCount: _informationControllerList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeSmall,
                      ),
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeSmall,
                          ),
                          child: CustomTextField(
                            titleText: widget.offlinePayment.input![i].userInput
                                .toString()
                                .replaceAll('_', ' '),
                            controller: _informationControllerList[i],
                            focusNode: _informationFocusList[i],
                            nextFocus:
                                i != _informationControllerList.length - 1
                                ? _informationFocusList[i + 1]
                                : null,
                            inputAction:
                                i != _informationControllerList.length - 1
                                ? TextInputAction.next
                                : TextInputAction.done,
                          ),
                        );
                      },
                    ),

                    Row(
                      children: [
                        const Spacer(),

                        CustomButton(
                          width: 100,
                          color: Theme.of(
                            context,
                          ).disabledColor.withOpacity(0.5),
                          textColor: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.color,
                          buttonText: 'cancel'.tr,
                          onPressed: () => Get.back(),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeLarge),

                        CustomButton(
                          width: 100,
                          buttonText: 'update'.tr,
                          isLoading: state.isLoading,
                          onPressed: () {
                            for (
                              int i = 0;
                              i < _informationControllerList.length;
                              i++
                            ) {
                              if (_informationControllerList[i].text.isEmpty) {
                                showCustomSnackBar(
                                  'please_provide_every_information'.tr,
                                );
                                break;
                              } else {
                                Map<String, String> data = {
                                  "_method": "put",
                                  "order_id": widget.orderId.toString(),
                                  "method_id": widget
                                      .offlinePayment
                                      .data!
                                      .methodId
                                      .toString(),
                                };

                                for (
                                  int j = 0;
                                  j < _informationControllerList.length;
                                  j++
                                ) {
                                  data.addAll({
                                    widget.offlinePayment.input![j].userInput
                                        .toString(): _informationControllerList[j]
                                        .text,
                                  });
                                }

                                context.read<PaymentBloc>().add(
                                  OfflineInfoUpdated(jsonEncode(data)),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
