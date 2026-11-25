import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/item/presentation/bloc/campaign_bloc.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/item/domain/models/basic_campaign_model.dart';
import 'package:ecommerce/helper/date_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/item_view.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CampaignScreen extends StatefulWidget {
  final BasicCampaignModel campaign;
  const CampaignScreen({super.key, required this.campaign});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  @override
  void initState() {
    super.initState();
    getIt<CampaignBloc>().add(
      CampaignDetailsRequested(widget.campaign.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).cardColor,
      body: BlocBuilder<CampaignBloc, CampaignState>(
        bloc: getIt<CampaignBloc>(),
        builder: (context, campaignState) {
          return CustomScrollView(
            slivers: [
              ResponsiveHelper.isDesktop(context)
                  ? SliverToBoxAdapter(
                      child: Container(
                        color: const Color(0xFF171A29),
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeLarge,
                          vertical: Dimensions.paddingSizeExtraLarge,
                        ),
                        alignment: Alignment.center,
                        child: Center(
                          child: SizedBox(
                            width: 1150,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                    child: CustomImage(
                                      fit: BoxFit.cover,
                                      height: 200,
                                      width: 1150,
                                      image:
                                          '${getIt<SplashBloc>().state.configModel!.baseUrls!.campaignImageUrl}/${widget.campaign.image}',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                      left: Dimensions.paddingSizeExtraLarge,
                                    ),
                                    child:
                                        campaignState.basicCampaign != null
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                campaignState.basicCampaign!.title!,
                                                style: robotoMedium.copyWith(
                                                  fontSize: Dimensions.fontSizeOverLarge,
                                                  color: Colors.white,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(
                                                height: Dimensions.paddingSizeDefault,
                                              ),
                                              Text(
                                                campaignState.basicCampaign!.description ?? '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: robotoRegular.copyWith(
                                                  fontSize: Dimensions.fontSizeLarge,
                                                  color: Theme.of(context).disabledColor,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: Dimensions.paddingSizeExtraLarge,
                                              ),
                                              campaignState.basicCampaign!.startTime != null
                                                  ? Row(
                                                      children: [
                                                        Image.asset(
                                                          Images.announcement,
                                                          height: 15,
                                                          width: 15,
                                                          color: Colors.white,
                                                        ),
                                                        const SizedBox(
                                                          width: Dimensions.paddingSizeExtraSmall,
                                                        ),
                                                        Text(
                                                          '${'campaign_schedule'.tr}:',
                                                          style: robotoRegular.copyWith(
                                                            fontSize: Dimensions.fontSizeExtraSmall,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: Dimensions.paddingSizeExtraSmall,
                                                        ),
                                                        Text(
                                                          '${DateConverter.stringToLocalDateOnly(campaignState.basicCampaign!.availableDateStarts!)}'
                                                          ' - ${DateConverter.stringToLocalDateOnly(campaignState.basicCampaign!.availableDateEnds!)}',
                                                          style: robotoMedium.copyWith(
                                                            fontSize: Dimensions.fontSizeExtraSmall,
                                                            color: Theme.of(context).primaryColor,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : const SizedBox(),
                                              const SizedBox(
                                                height: Dimensions.paddingSizeDefault,
                                              ),
                                              campaignState.basicCampaign!.startTime != null
                                                  ? Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.access_time_filled,
                                                          size: 16,
                                                          color: Colors.white,
                                                        ),
                                                        const SizedBox(
                                                          width: Dimensions.paddingSizeExtraSmall,
                                                        ),
                                                        Text(
                                                          '${'daily_time'.tr}:',
                                                          style: robotoRegular.copyWith(
                                                            fontSize: Dimensions.fontSizeExtraSmall,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: Dimensions.paddingSizeExtraSmall,
                                                        ),
                                                        Text(
                                                          '${DateConverter.convertTimeToTime(campaignState.basicCampaign!.startTime!)}'
                                                          ' - ${DateConverter.convertTimeToTime(campaignState.basicCampaign!.endTime!)}',
                                                          style: robotoMedium.copyWith(
                                                            fontSize: Dimensions.fontSizeExtraSmall,
                                                            color: Theme.of(context).primaryColor,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : const SizedBox(),
                                            ],
                                          )
                                        : const SizedBox(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : SliverAppBar(
                      expandedHeight: 140,
                      toolbarHeight: 50,
                      pinned: true,
                      floating: false,
                      backgroundColor: Colors.white,
                      leading: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                          ),
                          onPressed: () => Get.back(),
                        ),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: CustomImage(
                          fit: BoxFit.cover,
                          image:
                              '${getIt<SplashBloc>().state.configModel!.baseUrls!.campaignImageUrl}/${widget.campaign.image}',
                        ),
                      ),
                      actions: const [SizedBox()],
                    ),
              SliverToBoxAdapter(
                child: FooterView(
                  child: Container(
                    width: Dimensions.webMaxWidth,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(Dimensions.radiusExtraLarge),
                      ),
                    ),
                    child: Column(
                      children: [
                        campaignState.basicCampaign != null &&
                                !ResponsiveHelper.isDesktop(context)
                            ? Column(
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall,
                                        ),
                                        child: CustomImage(
                                          image:
                                              '${getIt<SplashBloc>().state.configModel!.baseUrls!.campaignImageUrl}/${campaignState.basicCampaign!.image}',
                                          height: 40,
                                          width: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: Dimensions.paddingSizeSmall,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              campaignState.basicCampaign!.title!,
                                              style: robotoMedium.copyWith(
                                                fontSize: Dimensions.fontSizeLarge,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              campaignState.basicCampaign!.description ?? '',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: robotoRegular.copyWith(
                                                fontSize: Dimensions.fontSizeSmall,
                                                color: Theme.of(context).disabledColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  campaignState.basicCampaign!.startTime != null
                                      ? Row(
                                          children: [
                                            Text(
                                              'campaign_schedule'.tr,
                                              style: robotoRegular.copyWith(
                                                fontSize: Dimensions.fontSizeExtraSmall,
                                                color: Theme.of(context).disabledColor,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: Dimensions.paddingSizeExtraSmall,
                                            ),
                                            Text(
                                              '${DateConverter.stringToLocalDateOnly(campaignState.basicCampaign!.availableDateStarts!)}'
                                              ' - ${DateConverter.stringToLocalDateOnly(campaignState.basicCampaign!.availableDateEnds!)}',
                                              style: robotoMedium.copyWith(
                                                fontSize: Dimensions.fontSizeExtraSmall,
                                                color: Theme.of(context).primaryColor,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  campaignState.basicCampaign!.startTime != null
                                      ? Row(
                                          children: [
                                            Text(
                                              'daily_time'.tr,
                                              style: robotoRegular.copyWith(
                                                fontSize: Dimensions.fontSizeExtraSmall,
                                                color: Theme.of(context).disabledColor,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: Dimensions.paddingSizeExtraSmall,
                                            ),
                                            Text(
                                              '${DateConverter.convertTimeToTime(campaignState.basicCampaign!.startTime!)}'
                                              ' - ${DateConverter.convertTimeToTime(campaignState.basicCampaign!.endTime!)}',
                                              style: robotoMedium.copyWith(
                                                fontSize: Dimensions.fontSizeExtraSmall,
                                                color: Theme.of(context).primaryColor,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                  const SizedBox(height: Dimensions.paddingSizeDefault),
                                ],
                              )
                            : ResponsiveHelper.isDesktop(context)
                            ? SizedBox(
                                width: 1150,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.paddingSizeSmall,
                                  ),
                                  child: Text(
                                    'store_list'.tr,
                                    style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        ItemsView(
                          isStore: true,
                          items: null,
                          padding: EdgeInsets.zero,
                          stores: campaignState.basicCampaign?.store,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
