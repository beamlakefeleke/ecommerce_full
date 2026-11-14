import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/loyalty/presentation/bloc/loyalty_bloc.dart';
import 'package:ecommerce/features/loyalty/presentation/bloc/loyalty_event.dart';
import 'package:ecommerce/features/loyalty/presentation/bloc/loyalty_state.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/profile/controllers/profile_controller.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/custom_text_field.dart';

class LoyaltyBottomSheetWidget extends StatefulWidget {
  final String amount;
  const LoyaltyBottomSheetWidget({super.key, required this.amount});

  @override
  State<LoyaltyBottomSheetWidget> createState() =>
      _LoyaltyBottomSheetWidgetState();
}

class _LoyaltyBottomSheetWidgetState extends State<LoyaltyBottomSheetWidget> {
  final TextEditingController _amountController = TextEditingController();

  int? exchangePointRate =
      Get.find<SplashController>().configModel!.loyaltyPointExchangeRate ?? 0;
  int? minimumExchangePoint =
      Get.find<SplashController>().configModel!.minimumPointToTransfer ?? 0;

  @override
  void initState() {
    super.initState();

    _amountController.text = exchangePointRate!.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoyaltyBloc, LoyaltyState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == LoyaltyActionStatus.success) {
          if (Get.isBottomSheetOpen ?? false) {
            Get.back();
          } else {
            Navigator.of(context).pop();
          }
          Get.find<ProfileController>().getUserInfo();
          showCustomSnackBar(
            'converted_successfully_transfer_to_your_wallet'.tr,
            isError: false,
          );
        } else if (state.actionStatus == LoyaltyActionStatus.failure) {
          showCustomSnackBar(state.message ?? 'error'.tr);
        }
      },
      child: Stack(
        children: [
          Container(
            width: ResponsiveHelper.isDesktop(context) ? 400 : 550,
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(Dimensions.radiusExtraLarge),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    ResponsiveHelper.isDesktop(context)
                        ? Images.loyaltyConvertIcon
                        : Images.creditIcon,
                    height: 50,
                    width: 50,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$exchangePointRate ${'points'.tr}= ',
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                      Text(
                        PriceConverter.convertPrice(1),
                        textDirection: TextDirection.ltr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text(
                    '(${'from'.tr} ${widget.amount} ${'points'.tr})',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).disabledColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text(
                    'amount_can_be_convert_into_wallet_money'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).disabledColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.paddingSizeExtraLarge
                        : Dimensions.paddingSizeLarge,
                  ),

                  SizedBox(
                    width: ResponsiveHelper.isDesktop(context) ? 260 : null,
                    child: CustomTextField(
                      titleText: 'enter_amount'.tr,
                      controller: _amountController,
                      inputType: TextInputType.phone,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(
                    height: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.paddingSizeExtraLarge
                        : Dimensions.paddingSizeLarge,
                  ),

                  BlocBuilder<LoyaltyBloc, LoyaltyState>(
                    builder: (context, state) {
                      return CustomButton(
                        width: ResponsiveHelper.isDesktop(context)
                            ? 136
                            : context.width / 3,
                        isBold: false,
                        buttonText: 'convert'.tr,
                        radius: ResponsiveHelper.isDesktop(context)
                            ? Dimensions.radiusSmall
                            : 50,
                        isLoading:
                            state.actionStatus ==
                            LoyaltyActionStatus.inProgress,
                        onPressed: () => _onConvertPressed(context),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.clear, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  void _onConvertPressed(BuildContext context) {
    if (_amountController.text.isEmpty) {
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }
      showCustomSnackBar('input_field_is_empty'.tr);
      return;
    }

    final int amount = int.parse(_amountController.text.trim());
    final int? point = Get.find<ProfileController>().userInfoModel!.loyaltyPoint;

    if (amount < minimumExchangePoint!) {
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }
      showCustomSnackBar(
        '${'please_exchange_more_then'.tr} $minimumExchangePoint ${'points'.tr}',
      );
    } else if (point! < amount) {
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }
      showCustomSnackBar('you_do_not_have_enough_point_to_exchange'.tr);
    } else {
      context.read<LoyaltyBloc>().add(LoyaltyPointConverted(amount));
    }
  }
}
