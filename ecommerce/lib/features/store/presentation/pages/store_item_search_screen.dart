import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';
import 'package:ecommerce/features/store/presentation/bloc/store_bloc.dart';
import 'package:ecommerce/features/store/presentation/bloc/store_event.dart';
import 'package:ecommerce/features/store/presentation/bloc/store_state.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/item_view.dart';
import 'package:ecommerce/common/widgets/paginated_list_view.dart';
import 'package:ecommerce/common/widgets/veg_filter_widget.dart';
import 'package:ecommerce/features/store/presentation/widgets/bottom_cart_widget.dart';
import 'package:get/get.dart';

class StoreItemSearchScreen extends StatefulWidget {
  final String? storeID;
  const StoreItemSearchScreen({super.key, required this.storeID});

  @override
  State<StoreItemSearchScreen> createState() => _StoreItemSearchScreenState();
}

class _StoreItemSearchScreenState extends State<StoreItemSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getIt<StoreBloc>().add(const StoreSearchDataInitialized());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreBloc, StoreState>(
      bloc: getIt<StoreBloc>(),
      builder: (context, storeState) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size(Dimensions.webMaxWidth, 60),
            child: Container(
              height: 60 + context.mediaQueryPadding.top,
              width: Dimensions.webMaxWidth,
              padding: EdgeInsets.only(top: context.mediaQueryPadding.top),
              color: Theme.of(context).cardColor,
              alignment: Alignment.center,
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                          textInputAction: TextInputAction.search,
                          cursorColor: Theme.of(context).primaryColor,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: 'search_item_in_store'.tr,
                            hintStyle: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(context).hintColor,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.all(
                              Dimensions.paddingSizeSmall,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusSmall,
                              ),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusSmall,
                              ),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.search,
                                color: Theme.of(context).hintColor,
                                size: 25,
                              ),
                              onPressed: () => getIt<StoreBloc>().add(
                                StoreSearchItemListRequested(
                                  searchText: _searchController.text.trim(),
                                  storeID: widget.storeID,
                                  offset: 1,
                                  type: storeState.searchType,
                                ),
                              ),
                            ),
                          ),
                          onSubmitted: (text) => getIt<StoreBloc>().add(
                            StoreSearchItemListRequested(
                              searchText: _searchController.text.trim(),
                              storeID: widget.storeID,
                              offset: 1,
                              type: storeState.searchType,
                            ),
                          ),
                        ),
                      ),
                      VegFilterWidget(
                        type: storeState.searchText.isNotEmpty
                            ? storeState.searchType
                            : null,
                        onSelected: (String type) {
                          getIt<StoreBloc>().add(
                            StoreSearchItemListRequested(
                              searchText: storeState.searchText,
                              storeID: widget.storeID,
                              offset: 1,
                              type: type,
                            ),
                          );
                        },
                        fromAppBar: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: ResponsiveHelper.isDesktop(context)
                ? null
                : const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: FooterView(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: PaginatedListView(
                  scrollController: _scrollController,
                  onPaginate: (int? offset) => getIt<StoreBloc>().add(
                    StoreSearchItemListRequested(
                      searchText: storeState.searchText,
                      storeID: widget.storeID,
                      offset: offset!,
                      type: storeState.searchType,
                    ),
                  ),
                  totalSize: storeState.storeSearchItemModel?.totalSize,
                  offset: storeState.storeSearchItemModel?.offset,
                  itemView: ItemsView(
                    isStore: false,
                    stores: null,
                    items: storeState.storeSearchItemModel?.items,
                    inStorePage: true,
                  ),
                ),
              ),
            ),
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
      },
    );
  }
}
