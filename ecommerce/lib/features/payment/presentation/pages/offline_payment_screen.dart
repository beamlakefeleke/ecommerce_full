import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/checkout/data/models/place_order_body_model.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:ecommerce/features/parcel/presentation/bloc/parcel_bloc.dart';
// Hide the parcel event names that clash with the payment bloc's events
// (OfflineBankSelected / OfflineMethodListRequested).
import 'package:ecommerce/features/parcel/presentation/bloc/parcel_event.dart'
    show ParcelOrderPlaced;
import 'package:ecommerce/features/parcel/presentation/bloc/parcel_state.dart';
import 'package:ecommerce/features/payment/data/models/offline_method_model.dart';
import 'package:ecommerce/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:ecommerce/features/payment/presentation/bloc/payment_event.dart';
import 'package:ecommerce/features/payment/presentation/bloc/payment_state.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/custom_text_field.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';

class OfflinePaymentScreen extends StatelessWidget {
  final PlaceOrderBodyModel placeOrderBody;
  final int zoneId;
  final double total;
  final double? maxCodOrderAmount;
  final bool fromCart;
  final bool isCashOnDeliveryActive;
  final bool forParcel;

  const OfflinePaymentScreen({
    super.key,
    required this.placeOrderBody,
    required this.zoneId,
    required this.total,
    required this.maxCodOrderAmount,
    required this.fromCart,
    required this.isCashOnDeliveryActive,
    required this.forParcel,
  });

  @override
  Widget build(BuildContext context) {
    // Screen-scoped PaymentBloc, seeded with the bank index the checkout/parcel
    // flow already selected.
    final int initialBankIndex = forParcel
        ? context.read<ParcelBloc>().state.selectedOfflineBankIndex
        : context.read<CheckoutBloc>().state.selectedOfflineBankIndex;
    return BlocProvider(
      create: (_) => getIt<PaymentBloc>()
        ..add(OfflineBankSelected(initialBankIndex))
        ..add(const OfflineMethodListRequested()),
      child: _OfflinePaymentView(
        placeOrderBody: placeOrderBody,
        zoneId: zoneId,
        total: total,
        maxCodOrderAmount: maxCodOrderAmount,
        fromCart: fromCart,
        isCashOnDeliveryActive: isCashOnDeliveryActive,
        forParcel: forParcel,
      ),
    );
  }
}

class _OfflinePaymentView extends StatefulWidget {
  final PlaceOrderBodyModel placeOrderBody;
  final int zoneId;
  final double total;
  final double? maxCodOrderAmount;
  final bool fromCart;
  final bool isCashOnDeliveryActive;
  final bool forParcel;

  const _OfflinePaymentView({
    required this.placeOrderBody,
    required this.zoneId,
    required this.total,
    required this.maxCodOrderAmount,
    required this.fromCart,
    required this.isCashOnDeliveryActive,
    required this.forParcel,
  });

  @override
  State<_OfflinePaymentView> createState() => _OfflinePaymentViewState();
}

class _OfflinePaymentViewState extends State<_OfflinePaymentView> {
  late PageController pageController;
  final TextEditingController _customerNoteController = TextEditingController();
  final FocusNode _customerNoteNode = FocusNode();

  /// Per-method dynamic input controllers/focus nodes (rule 4: owned by the
  /// screen State, not the bloc). Rebuilt whenever the selected bank changes.
  List<TextEditingController> _informationControllerList = [];
  List<FocusNode> _informationFocusList = [];
  int _builtForIndex = -1;

  /// orderId returned by the place-order step, pending the offline-info save.
  String? _placedOrderId;

  @override
  void initState() {
    super.initState();
    final int initialIndex = context
        .read<PaymentBloc>()
        .state
        .selectedBankIndex;
    pageController = PageController(
      viewportFraction: 0.85,
      initialPage: initialIndex,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    _customerNoteController.dispose();
    _customerNoteNode.dispose();
    for (final c in _informationControllerList) {
      c.dispose();
    }
    for (final f in _informationFocusList) {
      f.dispose();
    }
    super.dispose();
  }

  /// (Re)build the dynamic input controllers for [methodInformation].
  void _syncInformationControllers(
    int index,
    List<MethodInformations> methodInformation,
  ) {
    if (_builtForIndex == index &&
        _informationControllerList.length == methodInformation.length) {
      return;
    }
    for (final c in _informationControllerList) {
      c.dispose();
    }
    for (final f in _informationFocusList) {
      f.dispose();
    }
    _informationControllerList = List.generate(
      methodInformation.length,
      (_) => TextEditingController(),
    );
    _informationFocusList = List.generate(
      methodInformation.length,
      (_) => FocusNode(),
    );
    _builtForIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'offline_payment'.tr),
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            // Place-order result (checkout flow) → then save offline info.
            if (!widget.forParcel)
              BlocListener<CheckoutBloc, CheckoutState>(
                listenWhen: (p, c) =>
                    p.placeOrderResult != c.placeOrderResult &&
                    c.placeOrderResult != null,
                listener: (context, state) {
                  final result = state.placeOrderResult!;
                  if (result.isSuccess && result.orderId != '-1') {
                    _onOrderPlaced(context, result.orderId);
                  } else {
                    showCustomSnackBar(result.message);
                  }
                },
              ),
            // Place-order result (parcel flow): success carries orderId in
            // actionMessage.
            if (widget.forParcel)
              BlocListener<ParcelBloc, ParcelState>(
                listenWhen: (p, c) => p.actionStatus != c.actionStatus,
                listener: (context, state) {
                  if (state.actionStatus == ParcelActionStatus.success) {
                    _onOrderPlaced(context, state.actionMessage ?? '');
                  } else if (state.actionStatus == ParcelActionStatus.failure) {
                    showCustomSnackBar(state.actionMessage);
                  }
                },
              ),
            // Offline-info save result.
            BlocListener<PaymentBloc, PaymentState>(
              listenWhen: (p, c) => p.actionStatus != c.actionStatus,
              listener: (context, state) {
                if (state.actionStatus == OfflineInfoActionStatus.success &&
                    _placedOrderId != null &&
                    _placedOrderId!.isNotEmpty) {
                  Get.offAllNamed(
                    RouteHelper.getOrderDetailsRoute(
                      int.parse(_placedOrderId!),
                      fromOffline: true,
                      contactNumber: widget.placeOrderBody.contactPersonNumber,
                    ),
                  );
                } else if (state.actionStatus ==
                    OfflineInfoActionStatus.failure) {
                  showCustomSnackBar(state.errorMessage);
                }
              },
            ),
          ],
          child: BlocBuilder<PaymentBloc, PaymentState>(
            builder: (context, state) {
              if (state.status != PaymentStatus.loaded) {
                return const Center(child: CircularProgressIndicator());
              }

              final List<MethodInformations> methodInformation =
                  state.offlineMethodList.isNotEmpty
                  ? (state
                            .offlineMethodList[state.selectedBankIndex]
                            .methodInformations ??
                        [])
                  : [];
              _syncInformationControllers(
                state.selectedBankIndex,
                methodInformation,
              );

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: FooterView(
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                height: Dimensions.paddingSizeLarge,
                              ),

                              Image.asset(Images.offlinePayment, height: 100),
                              const SizedBox(
                                height: Dimensions.paddingSizeDefault,
                              ),

                              Text(
                                'pay_your_bill_using_the_info'.tr,
                                textAlign: TextAlign.center,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeLarge,
                              ),

                              SizedBox(
                                height: 160,
                                child: PageView.builder(
                                  onPageChanged: (int pageIndex) {
                                    context.read<PaymentBloc>().add(
                                      OfflineBankSelected(pageIndex),
                                    );
                                  },
                                  scrollDirection: Axis.horizontal,
                                  controller: pageController,
                                  itemCount: state.offlineMethodList.length,
                                  itemBuilder: (context, index) {
                                    bool selected =
                                        state.selectedBankIndex == index;
                                    return bankCard(
                                      context,
                                      state.offlineMethodList,
                                      index,
                                      selected,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeLarge,
                              ),

                              Text(
                                '${'amount'.tr} '
                                ' ${PriceConverter.convertPrice(widget.total)}',
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraLarge,
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeLarge,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'payment_info'.tr,
                                        style: robotoBold.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                        ),
                                      ),
                                    ),

                                    ListView.builder(
                                      itemCount:
                                          _informationControllerList.length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: Dimensions.paddingSizeSmall,
                                      ),
                                      itemBuilder: (context, i) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical:
                                                Dimensions.paddingSizeSmall,
                                          ),
                                          child: CustomTextField(
                                            titleText: methodInformation[i]
                                                .customerPlaceholder!,
                                            controller:
                                                _informationControllerList[i],
                                            focusNode: _informationFocusList[i],
                                            nextFocus:
                                                i !=
                                                    _informationControllerList
                                                            .length -
                                                        1
                                                ? _informationFocusList[i + 1]
                                                : _customerNoteNode,
                                          ),
                                        );
                                      },
                                    ),

                                    CustomTextField(
                                      titleText: 'write_your_note'.tr,
                                      controller: _customerNoteController,
                                      focusNode: _customerNoteNode,
                                      inputAction: TextInputAction.done,
                                    ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeLarge,
                                    ),
                                  ],
                                ),
                              ),

                              ResponsiveHelper.isDesktop(context)
                                  ? completeButton(state, methodInformation)
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  !ResponsiveHelper.isDesktop(context)
                      ? completeButton(state, methodInformation)
                      : const SizedBox(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Save offline info for the just-placed [orderId], then the PaymentBloc
  /// listener navigates on success.
  void _onOrderPlaced(BuildContext context, String orderId) {
    if (orderId.isEmpty || orderId == '-1') {
      return;
    }
    final state = context.read<PaymentBloc>().state;
    final List<MethodInformations> methodInformation =
        state.offlineMethodList.isNotEmpty
        ? (state
                  .offlineMethodList[state.selectedBankIndex]
                  .methodInformations ??
              [])
        : [];
    final String methodId = state.offlineMethodList[state.selectedBankIndex].id
        .toString();

    _placedOrderId = orderId;
    final Map<String, String> data = {
      "_method": "put",
      "order_id": orderId,
      "method_id": methodId,
      "customer_note": _customerNoteController.text,
    };
    for (int i = 0; i < methodInformation.length; i++) {
      data.addAll({
        methodInformation[i].customerInput!: _informationControllerList[i].text,
      });
    }
    context.read<PaymentBloc>().add(OfflineInfoSaved(jsonEncode(data)));
  }

  Widget completeButton(
    PaymentState state,
    List<MethodInformations>? methodInformation,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: CustomButton(
        buttonText: 'complete'.tr,
        isLoading: state.isLoading,
        width: ResponsiveHelper.isDesktop(context) ? 300 : 500,
        onPressed: () {
          bool complete = false;
          String text = '';
          for (int i = 0; i < methodInformation!.length; i++) {
            if (methodInformation[i].isRequired!) {
              if (_informationControllerList[i].text.isEmpty) {
                complete = false;
                text = methodInformation[i].customerPlaceholder!;
                break;
              } else {
                complete = true;
              }
            } else {
              complete = true;
            }
          }

          if (complete) {
            // Place the order; the BlocListener saves offline info on success.
            if (widget.forParcel) {
              context.read<ParcelBloc>().add(
                ParcelOrderPlaced(
                  placeOrderBody: widget.placeOrderBody,
                  isOfflinePay: true,
                ),
              );
            } else {
              context.read<CheckoutBloc>().add(
                CheckoutOrderPlaced(
                  body: widget.placeOrderBody,
                  isOfflinePay: true,
                ),
              );
            }
          } else {
            showCustomSnackBar(text);
          }
        },
      ),
    );
  }

  Widget bankCard(
    BuildContext context,
    List<OfflineMethodModel> offlineMethodList,
    int index,
    bool selected,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: selected
            ? Theme.of(context).cardColor
            : Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: selected
            ? const [BoxShadow(color: Colors.black12, blurRadius: 10)]
            : [],
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'bank_info'.tr,
                  style: robotoMedium.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const Spacer(),

                selected
                    ? Row(
                        children: [
                          Text(
                            'pay_on_this_account'.tr,
                            style: robotoMedium.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Icon(
                            Icons.check_circle_rounded,
                            size: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      )
                    : const SizedBox(),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            ListView.builder(
              itemCount: offlineMethodList[index].methodFields!.length,
              addRepaintBoundaries: false,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeExtraSmall,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${offlineMethodList[index].methodFields![i].inputName!.toString().replaceAll('_', ' ')} : ',
                        style: robotoMedium.copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.color!.withOpacity(0.5),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          offlineMethodList[index].methodFields![i].inputData!,
                          style: robotoMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
