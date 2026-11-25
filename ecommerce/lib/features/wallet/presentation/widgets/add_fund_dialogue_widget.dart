import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_state.dart';
import 'package:ecommerce/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:ecommerce/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:ecommerce/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/custom_text_field.dart';
import 'package:universal_html/html.dart' as html;

class AddFundDialogueWidget extends StatefulWidget {
  const AddFundDialogueWidget({super.key});

  @override
  State<AddFundDialogueWidget> createState() => _AddFundDialogueWidgetState();
}

class _AddFundDialogueWidgetState extends State<AddFundDialogueWidget> {
  final TextEditingController inputAmountController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    inputAmountController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletBloc = getIt<WalletBloc>();
    return BlocConsumer<WalletBloc, WalletState>(
      bloc: walletBloc,
      listenWhen: (prev, curr) =>
          prev.actionStatus == WalletActionStatus.addFundInProgress &&
          curr.actionStatus != WalletActionStatus.addFundInProgress,
      listener: (context, state) {
        if (state.actionStatus == WalletActionStatus.addFundSuccess &&
            state.fundRedirectUrl != null &&
            state.fundRedirectUrl!.isNotEmpty) {
          Get.back();
          if (GetPlatform.isWeb) {
            html.window.open(state.fundRedirectUrl!, '_self');
          } else {
            Get.toNamed(
              RouteHelper.getPaymentRoute(
                '0',
                0,
                '',
                0,
                false,
                '',
                addFundUrl: state.fundRedirectUrl!,
                guestId: '',
              ),
            );
          }
        } else if (state.actionStatus == WalletActionStatus.addFundFailure) {
          showCustomSnackBar(state.errorMessage ?? 'Something went wrong');
        }
      },
      builder: (context, walletState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => Get.back(),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).cardColor.withOpacity(0.5),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: const Icon(Icons.clear),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Container(
              constraints: BoxConstraints(
                minHeight: context.height * 0.2,
                maxHeight: context.height * 0.8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Theme.of(context).cardColor,
              ),
              width: context.width,
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Text(
                            'add_fund_to_wallet'.tr,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Text(
                            'add_fund_form_secured_digital_payment_gateways'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          CustomTextField(
                            titleText: 'enter_amount'.tr,
                            hintText: 'enter_amount'.tr,
                            inputType: TextInputType.number,
                            focusNode: focusNode,
                            inputAction: TextInputAction.done,
                            controller: inputAmountController,
                            textAlign: TextAlign.center,
                            onChanged: (String value) {
                              try {
                                if (double.parse(value) > 0) {
                                  walletBloc.add(
                                    const WalletAmountEmptyChanged(true),
                                  );
                                }
                              } catch (e) {
                                showCustomSnackBar('invalid_input'.tr);
                                walletBloc.add(
                                  const WalletAmountEmptyChanged(false),
                                );
                              }
                            },
                          ),

                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          walletState.amountEmpty &&
                                  inputAmountController.text.isNotEmpty
                              ? Row(
                                  children: [
                                    Text(
                                      'payment_method'.tr,
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: Dimensions.paddingSizeExtraSmall,
                                    ),

                                    Expanded(
                                      child: Text(
                                        'faster_and_secure_way_to_pay_bill'.tr,
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          walletState.amountEmpty &&
                                  inputAmountController.text.isNotEmpty
                              ? getIt<SplashBloc>()
                                        .state
                                        .configModel!
                                        .activePaymentMethodList!
                                        .isNotEmpty
                                    ? ListView.builder(
                                        itemCount: getIt<SplashBloc>()
                                            .state
                                            .configModel!
                                            .activePaymentMethodList!
                                            .length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          bool isSelected =
                                              getIt<SplashBloc>()
                                                  .state
                                                  .configModel!
                                                  .activePaymentMethodList![index]
                                                  .getWay! ==
                                              walletState.digitalPaymentName;
                                          return InkWell(
                                            onTap: () {
                                              walletBloc.add(
                                                WalletDigitalPaymentNameChanged(
                                                  getIt<SplashBloc>()
                                                      .state
                                                      .configModel!
                                                      .activePaymentMethodList![index]
                                                      .getWay!,
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Colors.blue.withOpacity(
                                                        0.05,
                                                      )
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Dimensions.radiusDefault,
                                                    ),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: Dimensions
                                                        .paddingSizeSmall,
                                                    vertical: Dimensions
                                                        .paddingSizeLarge,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 20,
                                                    width: 20,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: isSelected
                                                          ? Theme.of(
                                                              context,
                                                            ).primaryColor
                                                          : Theme.of(
                                                              context,
                                                            ).cardColor,
                                                      border: Border.all(
                                                        color: Theme.of(
                                                          context,
                                                        ).disabledColor,
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      Icons.check,
                                                      color: Theme.of(
                                                        context,
                                                      ).cardColor,
                                                      size: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeDefault,
                                                  ),

                                                  CustomImage(
                                                    height: 20,
                                                    fit: BoxFit.contain,
                                                    image:
                                                        '${getIt<SplashBloc>().state.configModel!.baseUrls!.gatewayImageUrl}/${getIt<SplashBloc>().state.configModel!.activePaymentMethodList![index].getWayImage!}',
                                                  ),
                                                  const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeSmall,
                                                  ),

                                                  Expanded(
                                                    child: Text(
                                                      getIt<SplashBloc>()
                                                          .state
                                                          .configModel!
                                                          .activePaymentMethodList![index]
                                                          .getWayTitle!,
                                                      style: robotoMedium
                                                          .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeDefault,
                                                          ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Text(
                                        'no_payment_method_is_available'.tr,
                                        style: robotoMedium,
                                      )
                              : const SizedBox(),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                        ],
                      ),
                    ),
                  ),

                  CustomButton(
                    buttonText: 'add_fund'.tr,
                    isLoading:
                        walletState.actionStatus ==
                        WalletActionStatus.addFundInProgress,
                    onPressed: () {
                      if (inputAmountController.text.isEmpty) {
                        showCustomSnackBar('please_provide_transfer_amount'.tr);
                      } else if (double.parse(inputAmountController.text) <=
                          0) {
                        showCustomSnackBar(
                          'you_can_not_add_less_then_zero_amount_in_wallet'.tr,
                        );
                      } else if (inputAmountController.text == '0') {
                        showCustomSnackBar(
                          'you_can_not_add_zero_amount_in_wallet'.tr,
                        );
                      } else if (walletState.digitalPaymentName == '') {
                        showCustomSnackBar('please_select_payment_method'.tr);
                      } else {
                        double amount = double.parse(
                          inputAmountController.text.replaceAll(
                            getIt<SplashBloc>()
                                .state
                                .configModel!
                                .currencySymbol!,
                            '',
                          ),
                        );
                        walletBloc.add(
                          WalletAddFundRequested(
                            amount: amount,
                            paymentMethod: walletState.digitalPaymentName,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
