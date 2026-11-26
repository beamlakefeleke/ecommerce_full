import 'package:ecommerce/features/splash/presentation/bloc/splash_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:ecommerce/features/banner/presentation/bloc/banner_bloc.dart';
import 'package:ecommerce/features/banner/presentation/bloc/banner_event.dart';
import 'package:ecommerce/features/item/presentation/bloc/campaign_bloc.dart';
import 'package:ecommerce/features/category/presentation/bloc/category_bloc.dart';
import 'package:ecommerce/features/category/presentation/bloc/category_event.dart';
import 'package:ecommerce/features/coupon/presentation/bloc/coupon_bloc.dart';
import 'package:ecommerce/features/flash_sale/presentation/bloc/flash_sale_bloc.dart';
import 'package:ecommerce/features/language/presentation/bloc/language_bloc.dart';
import 'package:ecommerce/features/location/presentation/bloc/location_bloc.dart';
import 'package:ecommerce/features/location/presentation/bloc/location_event.dart';
import 'package:ecommerce/features/location/presentation/bloc/location_state.dart';
import 'package:ecommerce/features/location/presentation/helper/location_helper.dart';
import 'package:ecommerce/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:ecommerce/features/item/presentation/bloc/item_bloc.dart';
import 'package:ecommerce/features/store/presentation/bloc/store_bloc.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_state.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_event.dart';
import 'package:ecommerce/features/address/presentation/bloc/address_bloc.dart';
import 'package:ecommerce/features/address/presentation/bloc/address_event.dart';
import 'package:ecommerce/features/parcel/presentation/bloc/parcel_bloc.dart';
import 'package:ecommerce/features/parcel/presentation/bloc/parcel_event.dart';
import 'package:ecommerce/helper/address_helper.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/common/widgets/web_menu_bar.dart';
import 'package:ecommerce/features/home/screens/web_new_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/home/widgets/module_view.dart';
import 'package:ecommerce/features/parcel/presentation/pages/parcel_category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static Future<void> loadData(bool reload, {bool fromModule = false}) async {
    LocationHelper.syncZoneData();
    getIt<FlashSaleBloc>().add(FlashSaleEmptied(fromModule: fromModule));
    if (getIt<SplashBloc>().state.module != null &&
        !getIt<SplashBloc>()
            .state
            .configModel!
            .moduleConfig!
            .module!
            .isParcel!) {
      getIt<BannerBloc>().add(BannerListRequested(reload: reload));
      if (getIt<SplashBloc>().state.module!.moduleType.toString() ==
          AppConstants.grocery) {
        getIt<FlashSaleBloc>().add(FlashSaleRequested(reload: reload));
      }
      if (getIt<SplashBloc>().state.module!.moduleType.toString() ==
          AppConstants.ecommerce) {
        getIt<ItemBloc>().add(const FeaturedCategoriesItemsRequested());
        getIt<FlashSaleBloc>().add(FlashSaleRequested(reload: reload));
      }
      getIt<BannerBloc>().add(PromotionalBannerRequested(reload: reload));
      getIt<ItemBloc>().add(DiscountedItemsRequested(reload: reload));
      getIt<CategoryBloc>().add(CategoryListRequested(reload: reload));
      getIt<StoreBloc>().add(
        PopularStoreListRequested(type: 'all', reload: reload),
      );
      getIt<CampaignBloc>().add(BasicCampaignListRequested(reload: reload));
      getIt<CampaignBloc>().add(ItemCampaignListRequested(reload: reload));
      getIt<ItemBloc>().add(PopularItemsRequested(reload: reload));
      getIt<StoreBloc>().add(
        LatestStoreListRequested(type: 'all', reload: reload),
      );
      getIt<ItemBloc>().add(ReviewedItemsRequested(reload: reload));
      getIt<ItemBloc>().add(RecommendedItemsRequested(reload: reload));
      getIt<StoreBloc>().add(
        const StoreListRequested(offset: 1, filterBy: 'all'),
      );
      getIt<StoreBloc>().add(const RecommendedStoreListRequested());
    }
    if (AuthHelper.isLoggedIn()) {
      getIt<ProfileBloc>().add(const ProfileInfoRequested());
      getIt<NotificationBloc>().add(NotificationListRequested(reload: reload));
      getIt<StoreBloc>().add(
        VisitAgainStoreListRequested(fromModule: fromModule),
      );
      getIt<CouponBloc>().add(const CouponListRequested());
    }
    getIt<SplashBloc>().add(const SplashModulesRequested());
    if (getIt<SplashBloc>().state.module == null &&
        getIt<SplashBloc>().state.configModel!.module == null) {
      getIt<BannerBloc>().add(const FeaturedBannerRequested());
      getIt<StoreBloc>().add(const FeaturedStoreListRequested());
      if (AuthHelper.isLoggedIn()) {
        getIt<AddressBloc>().add(const AddressListRequested());
      }
    }
    if (getIt<SplashBloc>().state.module != null &&
        getIt<SplashBloc>()
            .state
            .configModel!
            .moduleConfig!
            .module!
            .isParcel!) {
      getIt<ParcelBloc>().add(const ParcelCategoryListRequested());
    }
    if (getIt<SplashBloc>().state.module != null &&
        getIt<SplashBloc>().state.module!.moduleType.toString() ==
            AppConstants.pharmacy) {
      getIt<ItemBloc>().add(BasicMedicineRequested(reload: reload));
      getIt<StoreBloc>().add(const FeaturedStoreListRequested());
      getIt<ItemBloc>().add(const CommonConditionsRequested());
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    HomeScreen.loadData(false);
    if (!ResponsiveHelper.isWeb()) {
      getIt<LocationBloc>().add(
        ZoneRequested(
          lat: AddressHelper.getUserAddressFromSharedPref()!.latitude,
          lng: AddressHelper.getUserAddressFromSharedPref()!.longitude,
          markerLoad: false,
          updateInAddress: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SplashBloc, SplashState>(
      builder: (context, splashController) {
        bool showMobileModule =
            !ResponsiveHelper.isDesktop(context) &&
            splashController.module == null &&
            splashController.configModel!.module == null;
        bool isParcel =
            splashController.module != null &&
            splashController.configModel!.moduleConfig!.module!.isParcel!;
        bool isPharmacy =
            splashController.module != null &&
            splashController.module!.moduleType.toString() ==
                AppConstants.pharmacy;
        bool isShop =
            splashController.module != null &&
            splashController.module!.moduleType.toString() ==
                AppConstants.ecommerce;
        bool isGrocery =
            splashController.module != null &&
            splashController.module!.moduleType.toString() ==
                AppConstants.grocery;

        return Scaffold(
          appBar: ResponsiveHelper.isDesktop(context)
              ? const WebMenuBar()
              : null,
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          backgroundColor: Theme.of(context).colorScheme.background,
          body: isParcel
              ? const ParcelCategoryScreen()
              : SafeArea(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      getIt<SplashBloc>().add(const SplashRefreshingSet(true));
                      if (getIt<SplashBloc>().state.module != null) {
                        await LocationHelper.syncZoneData();
                        getIt<BannerBloc>().add(
                          const BannerListRequested(reload: true),
                        );
                        if (isGrocery) {
                          getIt<FlashSaleBloc>().add(
                            const FlashSaleRequested(reload: true),
                          );
                        }
                        getIt<BannerBloc>().add(
                          const PromotionalBannerRequested(reload: true),
                        );
                        getIt<ItemBloc>().add(
                          const DiscountedItemsRequested(reload: true),
                        );
                        getIt<CategoryBloc>().add(
                          const CategoryListRequested(reload: true),
                        );
                        getIt<StoreBloc>().add(
                          const PopularStoreListRequested(
                            type: 'all',
                            reload: true,
                          ),
                        );
                        getIt<CampaignBloc>().add(
                          const ItemCampaignListRequested(reload: true),
                        );
                        getIt<CampaignBloc>().add(
                          const BasicCampaignListRequested(reload: true),
                        );
                        getIt<ItemBloc>().add(
                          const PopularItemsRequested(reload: true),
                        );
                        getIt<StoreBloc>().add(
                          const LatestStoreListRequested(
                            type: 'all',
                            reload: true,
                          ),
                        );
                        getIt<ItemBloc>().add(
                          const ReviewedItemsRequested(reload: true),
                        );
                        getIt<StoreBloc>().add(
                          const StoreListRequested(offset: 1, filterBy: 'all'),
                        );
                        if (AuthHelper.isLoggedIn()) {
                          getIt<ProfileBloc>().add(
                            const ProfileInfoRequested(),
                          );
                          getIt<NotificationBloc>().add(
                            const NotificationListRequested(reload: true),
                          );
                          getIt<CouponBloc>().add(const CouponListRequested());
                        }
                        if (isPharmacy) {
                          getIt<ItemBloc>().add(
                            const BasicMedicineRequested(reload: true),
                          );
                          getIt<ItemBloc>().add(
                            const CommonConditionsRequested(),
                          );
                        }
                        if (isShop) {
                          getIt<FlashSaleBloc>().add(
                            const FlashSaleRequested(reload: true),
                          );
                          getIt<ItemBloc>().add(
                            const FeaturedCategoriesItemsRequested(
                              reload: true,
                            ),
                          );
                        }
                      } else {
                        getIt<BannerBloc>().add(
                          const FeaturedBannerRequested(),
                        );
                        getIt<SplashBloc>().add(const SplashModulesRequested());
                        if (AuthHelper.isLoggedIn()) {
                          getIt<AddressBloc>().add(
                            const AddressListRequested(),
                          );
                        }
                        getIt<StoreBloc>().add(
                          const FeaturedStoreListRequested(),
                        );
                      }
                      getIt<SplashBloc>().add(const SplashRefreshingSet(false));
                    },
                    child: ResponsiveHelper.isDesktop(context)
                        ? WebNewHomeScreen(scrollController: _scrollController)
                        : CustomScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              /// App Bar
                              SliverAppBar(
                                floating: true,
                                elevation: 0,
                                automaticallyImplyLeading: false,
                                surfaceTintColor: Theme.of(
                                  context,
                                ).colorScheme.background,
                                backgroundColor:
                                    ResponsiveHelper.isDesktop(context)
                                    ? Colors.transparent
                                    : Theme.of(context).colorScheme.background,
                                title: Center(
                                  child: Container(
                                    width: Dimensions.webMaxWidth,
                                    height: getIt<LanguageBloc>().state.isLtr
                                        ? 60
                                        : 70,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.background,
                                    child: Row(
                                      children: [
                                        (splashController.module != null &&
                                                splashController
                                                        .configModel!
                                                        .module ==
                                                    null)
                                            ? InkWell(
                                                onTap: () =>
                                                    getIt<SplashBloc>().add(
                                                      const SplashModuleRemoved(),
                                                    ),
                                                child: Image.asset(
                                                  Images.moduleIcon,
                                                  height: 25,
                                                  width: 25,
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge!.color,
                                                ),
                                              )
                                            : const SizedBox(),
                                        SizedBox(
                                          width:
                                              (splashController.module !=
                                                      null &&
                                                  splashController
                                                          .configModel!
                                                          .module ==
                                                      null)
                                              ? Dimensions.paddingSizeSmall
                                              : 0,
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () =>
                                                LocationHelper.navigateToLocationScreen(
                                                  'home',
                                                ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical:
                                                    Dimensions.paddingSizeSmall,
                                                horizontal:
                                                    ResponsiveHelper.isDesktop(
                                                      context,
                                                    )
                                                    ? Dimensions
                                                          .paddingSizeSmall
                                                    : 0,
                                              ),
                                              child: BlocBuilder<LocationBloc, LocationState>(
                                                builder: (context, locationState) {
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        AddressHelper.getUserAddressFromSharedPref()!
                                                            .addressType!
                                                            .tr,
                                                        style: robotoMedium.copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .color,
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Flexible(
                                                            child: Text(
                                                              AddressHelper.getUserAddressFromSharedPref()!
                                                                  .address!,
                                                              style: robotoRegular.copyWith(
                                                                color: Theme.of(
                                                                  context,
                                                                ).disabledColor,
                                                                fontSize: Dimensions
                                                                    .fontSizeSmall,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          Icon(
                                                            Icons.expand_more,
                                                            color: Theme.of(
                                                              context,
                                                            ).disabledColor,
                                                            size: 18,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          child: BlocBuilder<NotificationBloc, NotificationState>(
                                            builder: (context, notificationState) {
                                              return Stack(
                                                children: [
                                                  Icon(
                                                    CupertinoIcons.bell,
                                                    size: 25,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .color,
                                                  ),
                                                  notificationState
                                                          .hasNotification
                                                      ? Positioned(
                                                          top: 0,
                                                          right: 0,
                                                          child: Container(
                                                            height: 10,
                                                            width: 10,
                                                            decoration: BoxDecoration(
                                                              color: Theme.of(
                                                                context,
                                                              ).primaryColor,
                                                              shape: BoxShape
                                                                  .circle,
                                                              border: Border.all(
                                                                width: 1,
                                                                color: Theme.of(
                                                                  context,
                                                                ).cardColor,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : const SizedBox(),
                                                ],
                                              );
                                            },
                                          ),
                                          onTap: () => Get.toNamed(
                                            RouteHelper.getNotificationRoute(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: const [SizedBox()],
                              ),

                              /// Search Button
                              !showMobileModule
                                  ? SliverPersistentHeader(
                                      pinned: true,
                                      delegate: SliverDelegate(
                                        child: Center(
                                          child: Container(
                                            height: 50,
                                            width: Dimensions.webMaxWidth,
                                            // color: Theme.of(context).colorScheme.background,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeSmall,
                                            ),
                                            child: InkWell(
                                              onTap: () => Get.toNamed(
                                                RouteHelper.getSearchRoute(),
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: Dimensions
                                                          .paddingSizeSmall,
                                                    ),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(
                                                    context,
                                                  ).cardColor,
                                                  border: Border.all(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.2),
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      spreadRadius: 1,
                                                      blurRadius: 5,
                                                      offset: const Offset(
                                                        2,
                                                        3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      CupertinoIcons.search,
                                                      size: 25,
                                                      color: Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                    ),
                                                    const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        getIt<SplashBloc>()
                                                                .state
                                                                .configModel!
                                                                .moduleConfig!
                                                                .module!
                                                                .showRestaurantText!
                                                            ? 'search_food_or_restaurant'
                                                                  .tr
                                                            : 'search_item_or_store'
                                                                  .tr,
                                                        style: robotoRegular
                                                            .copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall,
                                                              color: Theme.of(
                                                                context,
                                                              ).hintColor,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SliverToBoxAdapter(),

                              SliverToBoxAdapter(
                                child: Center(
                                  child: SizedBox(
                                    width: Dimensions.webMaxWidth,
                                    child: ModuleView(
                                      splashController: splashController,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
        );
      },
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
