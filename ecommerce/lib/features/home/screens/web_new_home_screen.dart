import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/banner/presentation/bloc/banner_bloc.dart';
import 'package:ecommerce/features/banner/presentation/bloc/banner_event.dart';
import 'package:ecommerce/features/banner/presentation/bloc/banner_state.dart';
import 'package:ecommerce/features/category/presentation/bloc/category_bloc.dart';
import 'package:ecommerce/features/category/presentation/bloc/category_state.dart';
import 'package:ecommerce/features/item/presentation/bloc/campaign_bloc.dart';
import 'package:ecommerce/features/flash_sale/presentation/bloc/flash_sale_bloc.dart';
import 'package:ecommerce/features/store/presentation/bloc/store_bloc.dart';
import 'package:ecommerce/features/store/presentation/bloc/store_event.dart';
import 'package:ecommerce/features/location/presentation/helper/location_helper.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/home/widgets/web/middle_section_multiple_banner_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/module_widget.dart';
import 'package:ecommerce/features/home/widgets/web/web_basic_medicine_nearby_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/web_best_review_item_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/web_best_store_nearby_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/web_category_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/web_common_condition_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/web_coupon_banner_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/web_featured_categories_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/web_flash_sale_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/web_item_that_you_love_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/web_just_for_you_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/web_most_popular_item_banner_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/web_most_popular_item_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/web_new_banner_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/web_new_on_mart_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/web_new_on_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/web_populer_store_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/web_promotional_banner_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/web_recomanded_store_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/web_special_offer_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/web_visit_again_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/widgets/store_sorting_button.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/item_view.dart';
import 'package:ecommerce/common/widgets/paginated_list_view.dart';
import 'package:ecommerce/features/dashboard/widgets/address_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/home/widgets/bad_weather_widget.dart';

class WebNewHomeScreen extends StatefulWidget {
  final ScrollController scrollController;
  const WebNewHomeScreen({super.key, required this.scrollController});

  @override
  State<WebNewHomeScreen> createState() => _WebNewHomeScreenState();
}

class _WebNewHomeScreenState extends State<WebNewHomeScreen> {
  late bool _isLogin;
  bool active = false;

  @override
  void initState() {
    super.initState();
    _isLogin = AuthHelper.isLoggedIn();
    getIt<SplashBloc>().getSuggestedLocationStatus();

    if (_isLogin) {
      suggestAddressBottomSheet();
    }
  }

  Future<void> suggestAddressBottomSheet() async {
    active = await LocationHelper.checkLocationActive();
    if (!getIt<SplashBloc>().state.webSuggestedLocation && active) {
      Future.delayed(const Duration(seconds: 1), () {
        Get.dialog(
          const Center(
            child: SizedBox(
              height: 470,
              width: 550,
              child: AddressBottomSheetWidget(fromDialog: true),
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPharmacy =
        getIt<SplashBloc>().state.module != null &&
        getIt<SplashBloc>().state.module!.moduleType.toString() ==
            AppConstants.pharmacy;
    bool isFood =
        getIt<SplashBloc>().state.module != null &&
        getIt<SplashBloc>().state.module!.moduleType.toString() ==
            AppConstants.food;
    bool isShop =
        getIt<SplashBloc>().state.module != null &&
        getIt<SplashBloc>().state.module!.moduleType.toString() ==
            AppConstants.ecommerce;
    getIt<BannerBloc>().add(const BannerIndexChanged(0));
    bool isLoggedIn = AuthHelper.isLoggedIn();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(height: context.height),

        SingleChildScrollView(
          controller: widget.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              FooterView(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: BlocBuilder<BannerBloc, BannerState>(
                              builder: (context, bannerState) {
                                return bannerState.bannerImageList == null
                                    ? const WebNewBannerViewWidget(
                                        isFeatured: false,
                                      )
                                    : bannerState.bannerImageList!.isEmpty
                                    ? const SizedBox()
                                    : const WebNewBannerViewWidget(
                                        isFeatured: false,
                                      );
                              },
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),

                          BlocBuilder<FlashSaleBloc, FlashSaleState>(
                            builder: (context, flashState) {
                              bool isFlashSaleActive =
                                  (flashState.flashSaleModel?.activeProducts !=
                                      null &&
                                  flashState
                                      .flashSaleModel!
                                      .activeProducts!
                                      .isNotEmpty);
                              return Expanded(
                                flex: 1,
                                child: isFlashSaleActive
                                    ? const WebFlashSaleViewWidget()
                                    : const WebRecommendedStoreView(),
                              );
                            },
                          ),
                        ],
                      ),

                      const BadWeatherWidget(),

                      BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, categoryState) {
                          final categoryList =
                              categoryState.status == CategoryStatus.loaded
                              ? categoryState.categories
                              : null;
                          return categoryList == null
                              ? WebCategoryViewWidget(
                                  categoryList: categoryList,
                                )
                              : categoryList.isEmpty
                              ? const SizedBox()
                              : WebCategoryViewWidget(
                                  categoryList: categoryList,
                                );
                        },
                      ),

                      _isLogin
                          ? WebVisitAgainView(fromFood: isFood)
                          : const SizedBox(),

                      isPharmacy
                          ? const WebBasicMedicineNearbyViewWidget()
                          : isShop
                          ? const WebMostPopularItemViewWidget(
                              isShop: true,
                              isFood: false,
                            )
                          : const WebSpecialOfferView(
                              isFood: false,
                              isShop: false,
                            ),

                      (isPharmacy || isShop)
                          ? const MiddleSectionMultipleBannerViewWidget()
                          : isFood
                          ? const WebBestReviewItemViewWidget()
                          : const WebBestStoreNearbyViewWidget(),

                      isPharmacy
                          ? const WebBestStoreNearbyViewWidget()
                          : isFood
                          ? const WebNewOnViewWidget(isFood: true)
                          : isShop
                          ? const WebPopularStoresView()
                          : const WebMostPopularItemViewWidget(
                              isFood: false,
                              isShop: false,
                            ),

                      isPharmacy
                          ? const WebJustForYouViewWidget()
                          : isFood
                          ? const WebItemThatYouLoveViewWidget()
                          : isShop
                          ? const WebSpecialOfferView(
                              isFood: false,
                              isShop: true,
                            )
                          : BlocBuilder<CampaignBloc, CampaignState>(
                              builder: (context, campaignState) {
                                return campaignState.basicCampaignList == null
                                    ? const WebMostPopularItemBannerViewWidget()
                                    : campaignState.basicCampaignList!.isEmpty
                                    ? const SizedBox()
                                    : const WebMostPopularItemBannerViewWidget();
                              },
                            ),

                      isPharmacy
                          ? const WebNewOnViewWidget()
                          : isFood
                          ? const WebMostPopularItemViewWidget(
                              isFood: true,
                              isShop: false,
                            )
                          : isShop
                          ? const WebBestReviewItemViewWidget()
                          : const WebBestReviewItemViewWidget(),

                      isPharmacy
                          ? const WebCommonConditionViewWidget()
                          : isFood
                          ? const WebJustForYouViewWidget()
                          : isShop
                          ? const WebJustForYouViewWidget()
                          : /*const WebStoreWiseBannerView(),*/ const SizedBox(),

                      isPharmacy
                          ? const SizedBox()
                          : isFood
                          ? const WebNewOnMartViewWidget()
                          : isShop
                          ? const WebFeaturedCategoriesViewWidget()
                          : const WebJustForYouViewWidget(),

                      (isPharmacy || isFood)
                          ? const SizedBox()
                          : isShop
                          ? /*const WebStoreWiseBannerView()*/ const SizedBox()
                          : const WebItemThatYouLoveViewWidget(),

                      (isPharmacy || isFood)
                          ? const SizedBox()
                          : isShop
                          ? const WebItemThatYouLoveForShop()
                          : isLoggedIn
                          ? const WebCouponBannerViewWidget()
                          : const SizedBox(),

                      (isPharmacy || isFood)
                          ? const SizedBox()
                          : isShop
                          ? const WebNewOnViewWidget()
                          : const WebNewOnMartViewWidget(),

                      isFood
                          ? const SizedBox()
                          : const WebPromotionalBannerView(),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 20, 0, 5),
                        child: BlocBuilder<StoreBloc, StoreState>(
                          builder: (context, storeState) {
                            return Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${storeState.storeModel?.totalSize ?? 0} ${getIt<SplashBloc>().state.configModel!.moduleConfig!.module!.showRestaurantText! ? 'restaurants'.tr : 'stores'.tr}',
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                    ),
                                  ),
                                ),

                                storeState.storeModel != null
                                    ? Row(
                                        children: [
                                          InkWell(
                                            onTap: () => getIt<StoreBloc>().add(
                                              const StoreTypeChanged('all'),
                                            ),
                                            child: StoreSortingButton(
                                              storeType: 'all',
                                              storeTypeText: 'all'.tr,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: Dimensions.paddingSizeSmall,
                                          ),

                                          InkWell(
                                            onTap: () => getIt<StoreBloc>().add(
                                              const StoreTypeChanged(
                                                'delivery',
                                              ),
                                            ),
                                            child: StoreSortingButton(
                                              storeType: 'delivery',
                                              storeTypeText: 'delivery'.tr,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: Dimensions.paddingSizeSmall,
                                          ),

                                          InkWell(
                                            onTap: () => getIt<StoreBloc>().add(
                                              const StoreTypeChanged(
                                                'take_away',
                                              ),
                                            ),
                                            child: StoreSortingButton(
                                              storeType: 'take_away',
                                              storeTypeText: 'take_away'.tr,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                              ],
                            );
                          },
                        ),
                      ),

                      BlocBuilder<StoreBloc, StoreState>(
                        builder: (context, storeState) {
                          return PaginatedListView(
                            scrollController: widget.scrollController,
                            totalSize: storeState.storeModel?.totalSize,
                            offset: storeState.storeModel?.offset,
                            onPaginate: (int? offset) async =>
                                getIt<StoreBloc>().add(
                                  StoreListRequested(
                                    offset: offset!,
                                    filterBy: 'all',
                                  ),
                                ),
                            itemView: ItemsView(
                              isStore: true,
                              items: null,
                              stores: storeState.storeModel?.stores,
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveHelper.isDesktop(context)
                                    ? Dimensions.paddingSizeExtraSmall
                                    : Dimensions.paddingSizeSmall,
                                vertical: ResponsiveHelper.isDesktop(context)
                                    ? Dimensions.paddingSizeExtraSmall
                                    : 0,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Center(child: ModuleWidget()),
        ),
      ],
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;

  SliverDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != 50 ||
        oldDelegate.minExtent != 50 ||
        child != oldDelegate.child;
  }
}
