import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/store/presentation/bloc/store_bloc.dart';
import 'package:ecommerce/features/store/presentation/bloc/store_event.dart';
import 'package:ecommerce/features/store/presentation/bloc/store_state.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/item_view.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/common/widgets/web_page_title_widget.dart';
import 'package:get/get.dart';

class AllStoreScreen extends StatefulWidget {
  final bool isPopular;
  final bool isFeatured;
  final bool isNearbyStore;
  const AllStoreScreen({
    super.key,
    required this.isPopular,
    required this.isFeatured,
    required this.isNearbyStore,
  });

  @override
  State<AllStoreScreen> createState() => _AllStoreScreenState();
}

class _AllStoreScreenState extends State<AllStoreScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.isFeatured) {
      getIt<StoreBloc>().add(const FeaturedStoreListRequested());
    } else if (widget.isPopular) {
      getIt<StoreBloc>().add(
        const PopularStoreListRequested(type: 'all', reload: false, notify: false),
      );
    } else {
      getIt<StoreBloc>().add(
        const LatestStoreListRequested(type: 'all', reload: false, notify: false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreBloc, StoreState>(
      bloc: getIt<StoreBloc>(),
      builder: (context, storeState) {
        return Scaffold(
          appBar: CustomAppBar(
            title: widget.isFeatured
                ? 'featured_stores'.tr
                : widget.isPopular
                ? (getIt<SplashBloc>().state.configModel?.moduleConfig?.module
                              ?.showRestaurantText ?? false)
                      ? widget.isNearbyStore
                          ? 'best_store_nearby'.tr
                          : 'popular_restaurants'.tr
                      : widget.isNearbyStore
                      ? 'best_store_nearby'.tr
                      : 'popular_stores'.tr
                : '${'new_on'.tr} ${AppConstants.appName}',
            type: widget.isFeatured ? null : storeState.type,
            onVegFilterTap: (String type) {
              if (widget.isPopular) {
                getIt<StoreBloc>().add(
                  PopularStoreListRequested(type: type, reload: true, notify: true),
                );
              } else {
                getIt<StoreBloc>().add(
                  LatestStoreListRequested(type: type, reload: true, notify: true),
                );
              }
            },
          ),
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          body: RefreshIndicator(
            onRefresh: () async {
              if (widget.isFeatured) {
                getIt<StoreBloc>().add(const FeaturedStoreListRequested());
              } else if (widget.isPopular) {
                getIt<StoreBloc>().add(
                  PopularStoreListRequested(
                    type: getIt<StoreBloc>().state.type,
                    reload: true,
                  ),
                );
              } else {
                getIt<StoreBloc>().add(
                  LatestStoreListRequested(
                    type: getIt<StoreBloc>().state.type,
                    reload: true,
                  ),
                );
              }
            },
            child: SingleChildScrollView(
              controller: scrollController,
              child: FooterView(
                child: Column(
                  children: [
                    WebScreenTitleWidget(
                      title: widget.isFeatured
                          ? 'featured_stores'.tr
                          : widget.isPopular
                          ? (getIt<SplashBloc>().state.configModel?.moduleConfig
                                        ?.module?.showRestaurantText ?? false)
                                ? 'popular_restaurants'.tr
                                : 'popular_stores'.tr
                          : '${'new_on'.tr} ${AppConstants.appName}',
                    ),
                    SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: ItemsView(
                        isStore: true,
                        items: null,
                        isFeatured: widget.isFeatured,
                        noDataText: widget.isFeatured
                            ? 'no_store_available'.tr
                            : (getIt<SplashBloc>().state.configModel?.moduleConfig
                                          ?.module?.showRestaurantText ?? false)
                            ? 'no_restaurant_available'.tr
                            : 'no_store_available'.tr,
                        stores: widget.isFeatured
                            ? storeState.featuredStoreList
                            : widget.isPopular
                            ? storeState.popularStoreList
                            : storeState.latestStoreList,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
