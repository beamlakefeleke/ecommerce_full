import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/category/presentation/bloc/category_bloc.dart';
import 'package:ecommerce/features/category/presentation/bloc/category_event.dart';
import 'package:ecommerce/features/category/presentation/bloc/category_state.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/cart_widget.dart';
import 'package:ecommerce/common/widgets/item_view.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/common/widgets/veg_filter_widget.dart';
import 'package:ecommerce/common/widgets/web_menu_bar.dart';
import 'package:get/get.dart';

class CategoryItemScreen extends StatefulWidget {
  final String? categoryID;
  final String categoryName;
  const CategoryItemScreen({
    super.key,
    required this.categoryID,
    required this.categoryName,
  });

  @override
  CategoryItemScreenState createState() => CategoryItemScreenState();
}

class CategoryItemScreenState extends State<CategoryItemScreen>
    with TickerProviderStateMixin {
  final ScrollController _itemScroll = ScrollController();
  final ScrollController _storeScroll = ScrollController();
  final GlobalKey _scaffoldKey = GlobalKey();
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);

    final bloc = context.read<CategoryBloc>();
    bloc.add(SubCategoryListRequested(widget.categoryID));

    _itemScroll.addListener(() {
      final s = bloc.state;
      if (_itemScroll.position.pixels == _itemScroll.position.maxScrollExtent &&
          s.categoryItems != null &&
          !s.isLoading) {
        final int pageSize = ((s.pageSize ?? 0) / 10).ceil();
        if (s.offset < pageSize) {
          if (kDebugMode) print('loading next item page');
          bloc.add(const CategoryBottomLoaderShown());
          bloc.add(
            CategoryItemsRequested(
              categoryId: _activeCategoryId(s),
              offset: s.offset + 1,
              type: s.type,
            ),
          );
        }
      }
    });

    _storeScroll.addListener(() {
      final s = bloc.state;
      if (_storeScroll.position.pixels ==
              _storeScroll.position.maxScrollExtent &&
          s.categoryStores != null &&
          !s.isLoading) {
        final int pageSize = ((s.restPageSize ?? 0) / 10).ceil();
        if (s.offset < pageSize) {
          if (kDebugMode) print('loading next store page');
          bloc.add(const CategoryBottomLoaderShown());
          bloc.add(
            CategoryStoresRequested(
              categoryId: _activeCategoryId(s),
              offset: s.offset + 1,
              type: s.type,
            ),
          );
        }
      }
    });
  }

  String? _activeCategoryId(CategoryState s) {
    return s.subCategoryIndex == 0
        ? widget.categoryID
        : s.subCategories?[s.subCategoryIndex].id.toString();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _itemScroll.dispose();
    _storeScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final List<Item> items = state.isSearching
            ? (state.searchItems ?? [])
            : (state.categoryItems ?? []);
        final List<Store> stores = state.isSearching
            ? (state.searchStores ?? [])
            : (state.categoryStores ?? []);

        return PopScope(
          canPop: !state.isSearching,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && state.isSearching) {
              context.read<CategoryBloc>().add(const CategorySearchToggled());
            }
          },
          child: Scaffold(
            appBar: ResponsiveHelper.isDesktop(context)
                ? const WebMenuBar()
                : AppBar(
                    title: state.isSearching
                        ? TextField(
                            autofocus: true,
                            textInputAction: TextInputAction.search,
                            decoration: const InputDecoration(
                              hintText: 'Search...',
                              border: InputBorder.none,
                            ),
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                            onSubmitted: (query) =>
                                context.read<CategoryBloc>().add(
                                  CategorySearchRequested(
                                    query: query,
                                    categoryId: _activeCategoryId(state),
                                    type: state.type,
                                  ),
                                ),
                          )
                        : Text(
                            widget.categoryName,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.color,
                            ),
                          ),
                    centerTitle: true,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      onPressed: () {
                        if (state.isSearching) {
                          context.read<CategoryBloc>().add(
                            const CategorySearchToggled(),
                          );
                        } else {
                          Get.back();
                        }
                      },
                    ),
                    backgroundColor: Theme.of(context).cardColor,
                    elevation: 0,
                    actions: [
                      IconButton(
                        onPressed: () => context.read<CategoryBloc>().add(
                          const CategorySearchToggled(),
                        ),
                        icon: Icon(
                          state.isSearching ? Icons.close_sharp : Icons.search,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            Get.toNamed(RouteHelper.getCartRoute()),
                        icon: CartWidget(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          size: 25,
                        ),
                      ),
                      VegFilterWidget(
                        type: state.type,
                        fromAppBar: true,
                        onSelected: (String type) {
                          if (state.isSearching) {
                            context.read<CategoryBloc>().add(
                              CategorySearchRequested(
                                query: _activeCategoryId(state) ?? '',
                                categoryId: '1',
                                type: type,
                              ),
                            );
                          } else if (state.isStore) {
                            context.read<CategoryBloc>().add(
                              CategoryStoresRequested(
                                categoryId: _activeCategoryId(state),
                                offset: 1,
                                type: type,
                                notify: true,
                              ),
                            );
                          } else {
                            context.read<CategoryBloc>().add(
                              CategoryItemsRequested(
                                categoryId: _activeCategoryId(state),
                                offset: 1,
                                type: type,
                                notify: true,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
            endDrawer: const MenuDrawer(),
            endDrawerEnableOpenDragGesture: false,
            body: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(
                  children: [
                    // Sub-category strip
                    if (state.subCategories != null && !state.isSearching)
                      Container(
                        height: 40,
                        color: Theme.of(context).cardColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeExtraSmall,
                        ),
                        child: ListView.builder(
                          key: _scaffoldKey,
                          scrollDirection: Axis.horizontal,
                          itemCount: state.subCategories!.length,
                          padding: const EdgeInsets.only(
                            left: Dimensions.paddingSizeSmall,
                          ),
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (_, index) {
                            final selected = index == state.subCategoryIndex;
                            return InkWell(
                              onTap: () => context.read<CategoryBloc>().add(
                                SubCategoryIndexChanged(
                                  index,
                                  widget.categoryID,
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeSmall,
                                  vertical: Dimensions.paddingSizeExtraSmall,
                                ),
                                margin: const EdgeInsets.only(
                                  right: Dimensions.paddingSizeSmall,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall,
                                  ),
                                  color: selected
                                      ? Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.1)
                                      : Colors.transparent,
                                ),
                                child: Text(
                                  state.subCategories![index].name ?? '',
                                  style: selected
                                      ? robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(context).primaryColor,
                                        )
                                      : robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // Tab bar
                    Container(
                      color: Theme.of(context).cardColor,
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: Theme.of(context).primaryColor,
                        indicatorWeight: 3,
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Theme.of(context).disabledColor,
                        unselectedLabelStyle: robotoRegular.copyWith(
                          color: Theme.of(context).disabledColor,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                        labelStyle: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).primaryColor,
                        ),
                        tabs: [
                          Tab(text: 'item'.tr),
                          Tab(
                            text:
                                Get.find<SplashController>()
                                    .configModel!
                                    .moduleConfig!
                                    .module!
                                    .showRestaurantText!
                                ? 'restaurants'.tr
                                : 'stores'.tr,
                          ),
                        ],
                      ),
                    ),

                    // Tab content
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (n) {
                          if (n is ScrollEndNotification) {
                            if ((_tabController!.index == 1 &&
                                    !state.isStore) ||
                                (_tabController!.index == 0 && state.isStore)) {
                              final isStore = _tabController!.index == 1;
                              context.read<CategoryBloc>().add(
                                CategoryIsStoreSet(isStore),
                              );
                              if (state.isSearching) {
                                context.read<CategoryBloc>().add(
                                  CategorySearchRequested(
                                    query: state.searchText ?? '',
                                    categoryId: _activeCategoryId(state),
                                    type: state.type,
                                  ),
                                );
                              } else if (isStore) {
                                context.read<CategoryBloc>().add(
                                  CategoryStoresRequested(
                                    categoryId: _activeCategoryId(state),
                                    offset: 1,
                                    type: state.type,
                                  ),
                                );
                              } else {
                                context.read<CategoryBloc>().add(
                                  CategoryItemsRequested(
                                    categoryId: _activeCategoryId(state),
                                    offset: 1,
                                    type: state.type,
                                  ),
                                );
                              }
                            }
                          }
                          return false;
                        },
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            SingleChildScrollView(
                              controller: _itemScroll,
                              child: ItemsView(
                                isStore: false,
                                items: items.isEmpty ? null : items,
                                stores: null,
                                noDataText: 'no_category_item_found'.tr,
                              ),
                            ),
                            SingleChildScrollView(
                              controller: _storeScroll,
                              child: ItemsView(
                                isStore: true,
                                items: null,
                                stores: stores.isEmpty ? null : stores,
                                noDataText:
                                    Get.find<SplashController>()
                                        .configModel!
                                        .moduleConfig!
                                        .module!
                                        .showRestaurantText!
                                    ? 'no_category_restaurant_found'.tr
                                    : 'no_category_store_found'.tr,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Pagination loader
                    if (state.isLoading)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeSmall,
                          ),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
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
