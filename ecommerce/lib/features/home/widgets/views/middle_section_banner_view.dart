import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:ecommerce/features/item/presentation/bloc/campaign_bloc.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_state.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';

class MiddleSectionBannerView extends StatefulWidget {
  const MiddleSectionBannerView({super.key});

  @override
  State<MiddleSectionBannerView> createState() =>
      _MiddleSectionBannerViewState();
}

class _MiddleSectionBannerViewState extends State<MiddleSectionBannerView> {
  final CarouselSliderController carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    bool isPharmacy =
        getIt<SplashBloc>().state.module != null &&
        getIt<SplashBloc>().state.module!.moduleType.toString() ==
            AppConstants.pharmacy;

    return BlocBuilder<CampaignBloc, CampaignState>(
      builder: (context, state) {
        return state.basicCampaignList != null
            ? state.basicCampaignList!.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeDefault,
                        horizontal: Dimensions.paddingSizeSmall,
                      ),
                      child: Column(
                        children: [
                          CarouselSlider.builder(
                            carouselController: carouselController,
                            itemCount: state.basicCampaignList!.length,
                            options: CarouselOptions(
                              height: isPharmacy ? 187 : 135,
                              //autoPlay: true,
                              enlargeCenterPage: true,
                              disableCenter: true,
                              viewportFraction: 0.95,
                              onPageChanged: (index, reason) {
                                getIt<CampaignBloc>().add(
                                  CampaignCurrentIndexChanged(index),
                                );
                              },
                            ),
                            itemBuilder:
                                (
                                  BuildContext context,
                                  int itemIndex,
                                  int pageViewIndex,
                                ) {
                                  return InkWell(
                                    onTap: () => Get.toNamed(
                                      RouteHelper.getBasicCampaignRoute(
                                        state.basicCampaignList![itemIndex],
                                      ),
                                    ),
                                    child: Container(
                                      height: isPharmacy ? 187 : 135,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusLarge,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusLarge,
                                        ),
                                        child: CustomImage(
                                          image:
                                              '${getIt<SplashBloc>().state.configModel!.baseUrls!.campaignImageUrl}'
                                              '/${state.basicCampaignList![itemIndex].image}',
                                          fit: BoxFit.cover,
                                          height: 80,
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                          ),

                          const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: state.basicCampaignList!.map((bnr) {
                              int index = state.basicCampaignList!.indexOf(bnr);

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                child: index == state.currentIndex
                                    ? Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      )
                                    : Container(
                                        height: 5,
                                        width: 6,
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).primaryColor.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(
                                            Dimensions.radiusDefault,
                                          ),
                                        ),
                                      ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox()
            : MiddleSectionBannerShimmerView(isPharmacy: isPharmacy);
      },
    );
  }
}

class MiddleSectionBannerShimmerView extends StatelessWidget {
  final bool isPharmacy;
  const MiddleSectionBannerShimmerView({super.key, required this.isPharmacy});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: true,
      child: Column(
        children: [
          Stack(
            children: [
              CarouselSlider.builder(
                itemCount: 3,
                options: CarouselOptions(
                  height: isPharmacy ? 187 : 135,
                  enlargeCenterPage: true,
                  disableCenter: true,
                  viewportFraction: 0.95,
                ),
                itemBuilder:
                    (BuildContext context, int itemIndex, int pageViewIndex) {
                      return Container(
                        height: isPharmacy ? 187 : 135,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusLarge,
                          ),
                        ),
                      );
                    },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
