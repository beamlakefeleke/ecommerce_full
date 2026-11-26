import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce/features/banner/presentation/bloc/banner_bloc.dart';
import 'package:ecommerce/features/banner/presentation/bloc/banner_state.dart';
import 'package:ecommerce/features/banner/presentation/bloc/banner_event.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_state.dart';
import 'package:ecommerce/features/item/domain/models/basic_campaign_model.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class TaxiBannerView extends StatelessWidget {
  const TaxiBannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannerBloc, BannerState>(
      builder: (context, bannerController) {
        List<String?>? bannerList = bannerController.taxiBannerImageList;
        List<dynamic>? bannerDataList = bannerController.taxiBannerDataList;

        return (bannerList != null && bannerList.isEmpty)
            ? const SizedBox()
            : SizedBox(
                width: MediaQuery.of(context).size.width,
                height: GetPlatform.isDesktop ? 500 : 110,
                child: bannerList != null
                    ? Stack(
                        children: [
                          SizedBox(
                            height: 110,
                            width: context.width,
                            child: CarouselSlider.builder(
                              options: CarouselOptions(
                                autoPlay: true,
                                viewportFraction: 1,
                                autoPlayInterval: const Duration(seconds: 7),
                                onPageChanged: (index, reason) {
                                  context.read<BannerBloc>().add(
                                    BannerIndexChanged(index),
                                  );
                                },
                              ),
                              itemCount: bannerList.isEmpty
                                  ? 1
                                  : bannerList.length,
                              itemBuilder: (context, index, _) {
                                String? baseUrl =
                                    bannerDataList![index] is BasicCampaignModel
                                    ? getIt<SplashBloc>()
                                          .state
                                          .configModel!
                                          .baseUrls!
                                          .campaignImageUrl
                                    : getIt<SplashBloc>()
                                          .state
                                          .configModel!
                                          .baseUrls!
                                          .bannerImageUrl;
                                return InkWell(
                                  onTap: () async {},
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.grey[Get.isDarkMode
                                                  ? 800
                                                  : 200]!,
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    width: 500,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall,
                                      ),
                                      child: BlocBuilder<SplashBloc, SplashState>(
                                        builder: (context, splashController) {
                                          return CustomImage(
                                            image:
                                                '$baseUrl/${bannerList[index]}',
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          Positioned(
                            bottom: 5,
                            right: 0,
                            left: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: bannerList.map((bnr) {
                                int index = bannerList.indexOf(bnr);
                                return TabPageSelectorIndicator(
                                  backgroundColor:
                                      index == bannerController.currentIndex
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.5),
                                  borderColor: Theme.of(
                                    context,
                                  ).colorScheme.background,
                                  size: index == bannerController.currentIndex
                                      ? 10
                                      : 7,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      )
                    : Shimmer(
                        duration: const Duration(seconds: 2),
                        enabled: bannerList == null,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSmall,
                            ),
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
              );
      },
    );
  }
}
