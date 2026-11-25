import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_state.dart';
import 'package:ecommerce/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:ecommerce/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:ecommerce/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:ecommerce/helper/date_converter.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';

class BonusBannerWidget extends StatelessWidget {
  const BonusBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      bloc: getIt<WalletBloc>(),
      builder: (context, walletState) {
        return walletState.fundBonusList != null &&
                walletState.fundBonusList!.isNotEmpty &&
                getIt<SplashBloc>().state.configModel!.addFundStatus!
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: ResponsiveHelper.isDesktop(context) ? 110 : 105,
                    child: CarouselSlider.builder(
                      options: CarouselOptions(
                        autoPlay: true,
                        enlargeCenterPage: true,
                        disableCenter: true,
                        viewportFraction: 0.8,
                        autoPlayInterval: const Duration(seconds: 7),
                        onPageChanged: (index, reason) {
                          context.read<WalletBloc>().add(WalletCurrentIndexChanged(index));
                        },
                      ),
                      itemCount: walletState.fundBonusList!.length,
                      itemBuilder: (context, index, _) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusDefault,
                            ),
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                            ),
                            color: Theme.of(context).primaryColor.withOpacity(0.03),
                          ),
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeSmall,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      walletState.fundBonusList![index].title!,
                                      maxLines: 1,
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).primaryColor,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall,
                                    ),

                                    Text(
                                      '${'valid_till'.tr} ${DateConverter.stringToReadableString(walletState.fundBonusList![index].endDate!)}',
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall,
                                    ),

                                    Text(
                                      '${'add_fund_to_wallet_minimum'.tr} ${PriceConverter.convertPrice(walletState.fundBonusList![index].minimumAddAmount)} ${'and_enjoy'.tr} ${walletState.fundBonusList![index].bonusAmount} '
                                      '${walletState.fundBonusList![index].bonusType == 'amount' ? getIt<SplashBloc>().state.configModel!.currencySymbol : '%'} ${'bonus'.tr}',
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: walletState.fundBonusList!.map((bnr) {
                      int index = walletState.fundBonusList!.indexOf(bnr);
                      return TabPageSelectorIndicator(
                        backgroundColor: index == walletState.currentIndex
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).primaryColor.withOpacity(0.5),
                        borderColor: Theme.of(context).colorScheme.background,
                        size: index == walletState.currentIndex ? 10 : 7,
                      );
                    }).toList(),
                  ),
                ],
              )
            : const SizedBox();
      },
    );
  }
}
