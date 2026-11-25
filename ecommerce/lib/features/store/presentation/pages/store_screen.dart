import 'package:ecommerce/features/item/domain/models/basic_medicine_model.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';
import 'package:ecommerce/features/home/widgets/components/review_item_card_widget.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/presentation/bloc/store_bloc.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/category/presentation/bloc/category_bloc.dart';
import 'package:ecommerce/features/category/presentation/bloc/category_event.dart';
import 'package:ecommerce/features/category/presentation/bloc/category_state.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/category/data/models/category_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/features/checkout/presentation/pages/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/store/presentation/widgets/bottom_cart_widget.dart';

class StoreScreen extends StatefulWidget {
  final Store? store;
  final bool fromModule;
  final String slug;
  const StoreScreen({
    super.key,
    required this.store,
    required this.fromModule,
    this.slug = '',
  });

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initDataCall();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> initDataCall() async {
    final storeBloc = getIt<StoreBloc>();

    if (storeBloc.state.isSearching) {
      storeBloc.add(const StoreSearchStatusToggled());
    }
    storeBloc.add(const StoreAnimationHidden());

    storeBloc.add(
      StoreDetailsRequested(
        storeID: widget.store!.id.toString(),
        fromModule: widget.fromModule,
        slug: widget.slug,
      ),
    );

    // After details load, trigger sub-lists. We listen for the state change.
    storeBloc.stream.firstWhere((s) => !s.isLoading).then((_) {
      final currentState = storeBloc.state;
      final int? storeId =
          widget.store!.id ?? currentState.store?.id;
      if (storeId != null) {
        storeBloc.add(StoreBannerListRequested(storeId: storeId));
        storeBloc.add(
          StoreRecommendedItemListRequested(storeId: storeId, reload: false),
        );
        storeBloc.add(
          StoreItemListRequested(storeID: storeId, offset: 1, type: 'all'),
        );
      }
      storeBloc.add(const StoreButtonAnimationShown());
    });

    if (getIt<CategoryBloc>().state.categories.isEmpty) {
      getIt<CategoryBloc>().add(const CategoryListRequested());
    }

    scrollController.addListener(() {
      final storeBloc = getIt<StoreBloc>();
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (storeBloc.state.showFavButton) {
          storeBloc.add(const StoreFavVisibilityChanged());
          storeBloc.add(const StoreAnimationHidden());
        }
      } else {
        if (!storeBloc.state.showFavButton) {
          storeBloc.add(const StoreFavVisibilityChanged());
          storeBloc.add(const StoreButtonAnimationShown());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: BlocBuilder<StoreBloc, StoreState>(
          bloc: getIt<StoreBloc>(),
          builder: (context, storeState) {
            return BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, categoryState) {
                Store? store;
                if (storeState.store != null &&
                    storeState.store!.name != null &&
                    categoryState.categories.isNotEmpty) {
                  store = storeState.store;
                }

                return (store != null && categoryState.categories.isNotEmpty)
                    ? _buildContent(context, storeState)
                    : const Center(child: CircularProgressIndicator());
              },
            );
          },
        ),
      ),
      floatingActionButton: BlocBuilder<StoreBloc, StoreState>(
        bloc: getIt<StoreBloc>(),
        builder: (context, storeState) {
          return Visibility(
            visible:
                storeState.showFavButton &&
                (getIt<SplashBloc>().state.configModel?.moduleConfig?.module
                        ?.orderAttachment ?? false) &&
                (storeState.store?.prescriptionOrder ?? false) &&
                (getIt<SplashBloc>().state.configModel?.prescriptionStatus ?? false) &&
                AuthHelper.isLoggedIn(),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    width: storeState.currentState
                        ? 0
                        : ResponsiveHelper.isDesktop(context)
                        ? 180
                        : 150,
                    height: 30,
                    curve: Curves.linear,
                    child: Center(
                      child: Text(
                        'prescription_order'.tr,
                        textAlign: TextAlign.center,
                        style: robotoMedium.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.toNamed(
                      RouteHelper.getCheckoutRoute(
                        'prescription',
                        storeId: storeState.store?.id,
                      ),
                      arguments: CheckoutScreen(
                        fromCart: false,
                        cartList: null,
                        storeId: storeState.store?.id,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusSmall,
                        ),
                      ),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Image.asset(
                        Images.prescriptionIcon,
                        height: 25,
                        width: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          return cartState.cartList.isNotEmpty &&
                  !ResponsiveHelper.isDesktop(context)
              ? const BottomCartWidget()
              : const SizedBox();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, StoreState storeState) {
    final List<Item> products = [];
    final List<Categories> categoryList = [];

    // The store screen shows featured categories items (from ItemBloc)
    // — same logic as before but without ItemController.
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          sliver: storeState.storeItemModel?.items?.isNotEmpty == true
              ? SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: Dimensions.paddingSizeDefault,
                    mainAxisSpacing: Dimensions.paddingSizeDefault,
                    mainAxisExtent: 257,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = storeState.storeItemModel!.items![index];
                    return ReviewItemCard(
                      key: ValueKey(item.id),
                      isFeatured: true,
                      item: item,
                    );
                  }, childCount: storeState.storeItemModel!.items!.length),
                )
              : SliverToBoxAdapter(
                  child: storeState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const Center(child: Text('No products found')),
                ),
        ),
      ],
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 100});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height ||
        oldDelegate.minExtent != height ||
        child != oldDelegate.child;
  }
}

class CategoryProduct {
  CategoryModel category;
  List<Item> products;
  CategoryProduct(this.category, this.products);
}
