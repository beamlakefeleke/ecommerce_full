import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/item/presentation/bloc/campaign_bloc.dart';
import 'package:ecommerce/features/item/presentation/helpers/item_helper.dart';
import 'package:ecommerce/features/language/presentation/bloc/language_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'package:ecommerce/common/widgets/hover/on_hover.dart';
import 'package:ecommerce/features/home/widgets/web/widgets/arrow_icon_button.dart';

class WebJustForYouViewWidget extends StatefulWidget {
  const WebJustForYouViewWidget({super.key});

  @override
  State<WebJustForYouViewWidget> createState() =>
      _WebJustForYouViewWidgetState();
}

class _WebJustForYouViewWidgetState extends State<WebJustForYouViewWidget> {
  ScrollController scrollController = ScrollController();
  bool showBackButton = false;
  bool showForwardButton = false;
  bool isFirstTime = true;

  @override
  void initState() {
    scrollController.addListener(_checkScrollPosition);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    setState(() {
      if (scrollController.position.pixels <= 0) {
        showBackButton = false;
      } else {
        showBackButton = true;
      }

      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        showForwardButton = false;
      } else {
        showForwardButton = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CampaignBloc, CampaignState>(
      builder: (context, state) {
        if (state.itemCampaignList != null &&
            state.itemCampaignList!.length > 5 &&
            isFirstTime) {
          showForwardButton = true;
          isFirstTime = false;
        }

        return state.itemCampaignList != null
            ? state.itemCampaignList!.isNotEmpty
                  ? Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeDefault,
                              ),
                              child: Text(
                                'just_for_you'.tr,
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 185,
                              width: Get.width,
                              child: ListView.builder(
                                controller: scrollController,
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: state.itemCampaignList!.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: Dimensions.paddingSizeDefault,
                                      top: Dimensions.paddingSizeDefault,
                                      left:
                                          getIt<LanguageBloc>().state.isLtr
                                          ? 0
                                          : Dimensions.paddingSizeDefault,
                                      right:
                                          getIt<LanguageBloc>().state.isLtr
                                          ? Dimensions.paddingSizeDefault
                                          : 0,
                                    ),
                                    child: OnHover(
                                      isItem: true,
                                      child: InkWell(
                                        hoverColor: Colors.transparent,
                                        onTap: () =>
                                            ItemHelper.navigateToItemPage(
                                              state.itemCampaignList![index],
                                              context,
                                              isCampaign: true,
                                            ),
                                        child: Container(
                                          height: 185,
                                          width: 185,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusDefault,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusDefault,
                                            ),
                                            child: CustomImage(
                                              image:
                                                  '${getIt<SplashBloc>().state.configModel!.baseUrls!.campaignImageUrl}'
                                                  '/${state.itemCampaignList![index].image}',
                                              fit: BoxFit.cover,
                                              height: 185,
                                              width: 185,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        if (showBackButton)
                          Positioned(
                            top: 130,
                            left: 0,
                            child: ArrowIconButton(
                              isRight: false,
                              onTap: () => scrollController.animateTo(
                                scrollController.offset -
                                    Dimensions.webMaxWidth,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              ),
                            ),
                          ),

                        if (showForwardButton)
                          Positioned(
                            top: 130,
                            right: 0,
                            child: ArrowIconButton(
                              onTap: () => scrollController.animateTo(
                                scrollController.offset +
                                    Dimensions.webMaxWidth,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              ),
                            ),
                          ),
                      ],
                    )
                  : const SizedBox()
            : const WebJustForYouShimmerView();
      },
    );
  }
}

class WebJustForYouShimmerView extends StatelessWidget {
  const WebJustForYouShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeDefault,
              ),
              child: Text(
                'just_for_you'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
            ),

            SizedBox(
              height: 185,
              width: Get.width,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: Dimensions.paddingSizeDefault,
                      top: Dimensions.paddingSizeDefault,
                      left: getIt<LanguageBloc>().state.isLtr
                          ? 0
                          : Dimensions.paddingSizeDefault,
                      right: getIt<LanguageBloc>().state.isLtr
                          ? Dimensions.paddingSizeDefault
                          : 0,
                    ),
                    child: Shimmer(
                      duration: const Duration(seconds: 2),
                      enabled: true,
                      child: Container(
                        height: 185,
                        width: 185,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

