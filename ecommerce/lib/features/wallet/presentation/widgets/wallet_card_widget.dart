import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/language/presentation/bloc/language_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_state.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_state.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/features/wallet/presentation/widgets/add_fund_dialogue_widget.dart';

class WalletCardWidget extends StatelessWidget {
  final JustTheController tooltipController;
  const WalletCardWidget({super.key, required this.tooltipController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      bloc: getIt<ProfileBloc>(),
      builder: (context, profileState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(
                    ResponsiveHelper.isDesktop(context)
                        ? 35
                        : Dimensions.paddingSizeExtraLarge,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'wallet_amount'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Row(
                        children: [
                          Text(
                            PriceConverter.convertPrice(
                              profileState.userInfoModel!.walletBalance,
                            ),
                            textDirection: TextDirection.ltr,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeOverLarge,
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          getIt<SplashBloc>().state
                                      .configModel!
                                      .addFundStatus! &&
                                  getIt<SplashBloc>().state
                                      .configModel!
                                      .digitalPayment!
                              ? JustTheTooltip(
                                  backgroundColor: Colors.black87,
                                  controller: tooltipController,
                                  preferredDirection: AxisDirection.right,
                                  tailLength: 14,
                                  tailBaseWidth: 20,
                                  content: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'if_you_want_to_add_fund_to_your_wallet_then_click_add_fund_button'
                                          .tr,
                                      style: robotoRegular.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () =>
                                        tooltipController.showTooltip(),
                                    child: Icon(
                                      Icons.info_outline,
                                      color: Theme.of(context).cardColor,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ],
                  ),
                ),

                getIt<SplashBloc>().state.configModel!.addFundStatus! &&
                        getIt<SplashBloc>().state
                            .configModel!
                            .digitalPayment!
                    ? Positioned(
                        top: 30,
                        right: getIt<LanguageBloc>().state.isLtr
                            ? 20
                            : null,
                        left: getIt<LanguageBloc>().state.isLtr
                            ? null
                            : 10,
                        child: InkWell(
                          onTap: () {
                            Get.dialog(
                              const Dialog(
                                backgroundColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                child: SizedBox(
                                  width: 500,
                                  child: SingleChildScrollView(
                                    child: AddFundDialogueWidget(),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).cardColor,
                            ),
                            padding: const EdgeInsets.all(
                              Dimensions.paddingSizeExtraSmall,
                            ),
                            child: const Icon(Icons.add),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
            ResponsiveHelper.isDesktop(context)
                ? const SizedBox()
                : const SizedBox(height: Dimensions.paddingSizeLarge),
            ResponsiveHelper.isDesktop(context)
                ? const SizedBox(height: Dimensions.paddingSizeDefault)
                : const SizedBox(),

            ResponsiveHelper.isDesktop(context)
                ? Text(
                    'how_to_use'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  )
                : const SizedBox(),
            ResponsiveHelper.isDesktop(context)
                ? const SizedBox(height: Dimensions.paddingSizeDefault)
                : const SizedBox(),

            !ResponsiveHelper.isDesktop(context)
                ? const SizedBox()
                : const WalletStepper(),
          ],
        );
      },
    );
  }
}

class WalletStepper extends StatelessWidget {
  const WalletStepper({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: Dimensions.paddingSizeExtraSmall,
                ),
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),

              Expanded(
                child: VerticalDivider(
                  thickness: 3,
                  color: Theme.of(context).primaryColor.withOpacity(0.30),
                ),
              ),

              Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),

              Expanded(
                child: VerticalDivider(
                  thickness: 3,
                  color: Theme.of(context).primaryColor.withOpacity(0.30),
                ),
              ),

              Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),

              Expanded(
                child: VerticalDivider(
                  thickness: 3,
                  color: Theme.of(context).primaryColor.withOpacity(0.30),
                ),
              ),

              Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'earn_money_to_your_wallet_by_completing_the_offer_challenged'
                      .tr,
                  style: robotoRegular,
                ),
                Text(
                  'convert_your_loyalty_points_into_wallet_money'.tr,
                  style: robotoRegular,
                ),
                Text(
                  'amin_also_reward_their_top_customers_with_wallet_money'.tr,
                  style: robotoRegular,
                ),
                Text(
                  'send_your_wallet_money_while_order'.tr,
                  style: robotoRegular,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
