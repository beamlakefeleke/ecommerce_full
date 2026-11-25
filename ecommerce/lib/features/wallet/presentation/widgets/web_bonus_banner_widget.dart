import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_state.dart';
import 'package:ecommerce/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:ecommerce/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:ecommerce/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:ecommerce/helper/date_converter.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WebBonusBannerWidget extends StatelessWidget {
  const WebBonusBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    return BlocBuilder<WalletBloc, WalletState>(
      bloc: getIt<WalletBloc>(),
      builder: (context, walletState) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: Dimensions.paddingSizeSmall,
          ),
          alignment: Alignment.center,
          child: SizedBox(
            width: 1210,
            height: 130,
            child: walletState.fundBonusList != null
                ? Stack(
                    clipBehavior: Clip.none,
                    fit: StackFit.expand,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                        ),
                        child: PageView.builder(
                          controller: pageController,
                          itemCount:
                              (walletState.fundBonusList!.length / 2)
                                  .ceil(),
                          itemBuilder: (context, index) {
                            int index1 = index * 2;
                            int index2 = (index * 2) + 1;
                            bool hasSecond =
                                index2 < walletState.fundBonusList!.length;

                            return Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault,
                                      ),
                                      border: Border.all(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.03),
                                    ),
                                    padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeSmall,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                walletState
                                                    .fundBonusList![index1]
                                                    .title!,
                                                maxLines: 1,
                                                style: robotoBold.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeDefault,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeExtraSmall,
                                              ),

                                              Text(
                                                '${'valid_till'.tr} ${DateConverter.stringToReadableString(walletState.fundBonusList![index1].endDate!)}',
                                                style: robotoMedium.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeExtraSmall,
                                              ),

                                              Text(
                                                '${'add_fund_to_wallet_minimum'.tr} ${PriceConverter.convertPrice(walletState.fundBonusList![index1].minimumAddAmount)} ${'and_enjoy'.tr} ${walletState.fundBonusList![index1].bonusAmount} '
                                                '${walletState.fundBonusList![index1].bonusType == 'amount' ? getIt<SplashBloc>().state.configModel!.currencySymbol : '%'} ${'bonus'.tr}',
                                                style: robotoRegular.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Image.asset(
                                          Images.walletBonus,
                                          height: 65,
                                          width: 65,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: Dimensions.paddingSizeLarge,
                                ),

                                Expanded(
                                  child: hasSecond
                                      ? Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusDefault,
                                            ),
                                            border: Border.all(
                                              color:
                                                  Theme.of(context).primaryColor,
                                            ),
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.03),
                                          ),
                                          padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeSmall,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      walletState
                                                          .fundBonusList![index2]
                                                          .title!,
                                                      maxLines: 1,
                                                      style: robotoBold.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeDefault,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),

                                                    Text(
                                                      '${'valid_till'.tr} ${DateConverter.stringToReadableString(walletState.fundBonusList![index2].endDate!)}',
                                                      style: robotoMedium
                                                          .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                          ),
                                                    ),
                                                    const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),

                                                    Text(
                                                      '${'add_fund_to_wallet_minimum'.tr} ${PriceConverter.convertPrice(walletState.fundBonusList![index2].minimumAddAmount)} ${'and_enjoy'.tr} ${walletState.fundBonusList![index2].bonusAmount} '
                                                      '${walletState.fundBonusList![index2].bonusType == 'amount' ? getIt<SplashBloc>().state.configModel!.currencySymbol : '%'} ${'bonus'.tr}',
                                                      style: robotoRegular
                                                          .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                            color: Theme.of(context)
                                                                .primaryColor,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Image.asset(
                                                Images.walletBonus,
                                                height: 65,
                                                width: 65,
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                              ],
                            );
                          },
                          onPageChanged: (int index) =>
                              context.read<WalletBloc>().add(WalletCurrentIndexChanged(index)),
                        ),
                      ),

                      walletState.currentIndex != 0
                          ? Positioned(
                              top: 0,
                              bottom: 0,
                              left: 0,
                              child: InkWell(
                                onTap: () => pageController.previousPage(
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeInOut,
                                ),
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).cardColor,
                                  ),
                                  child: const Icon(Icons.arrow_back),
                                ),
                              ),
                            )
                          : const SizedBox(),

                      walletState.currentIndex !=
                              ((walletState.fundBonusList!.length / 2)
                                      .ceil() -
                                  1)
                          ? Positioned(
                              top: 0,
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () => pageController.nextPage(
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeInOut,
                                ),
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).cardColor,
                                  ),
                                  child: const Icon(Icons.arrow_forward),
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  )
                : WebBannerShimmer(walletState: walletState),
          ),
        );
      },
    );
  }
}

class WebBannerShimmer extends StatelessWidget {
  final WalletState walletState;
  const WebBannerShimmer({super.key, required this.walletState});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: walletState.fundBonusList == null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeLarge,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: Colors.grey[300],
                ),
              ),
            ),

            const SizedBox(width: Dimensions.paddingSizeLarge),

            Expanded(
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: Colors.grey[300],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
