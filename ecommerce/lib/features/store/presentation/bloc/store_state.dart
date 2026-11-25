import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/features/category/data/models/category_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/data/models/cart_suggested_item_model.dart';
import 'package:ecommerce/features/store/data/models/recommended_product_model.dart';
import 'package:ecommerce/features/store/data/models/store_banner_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';

enum StoreStatus { initial, loading, loaded, error }

class StoreState extends Equatable {
  final StoreStatus status;

  // paginated store list (all-stores screen)
  final StoreModel? storeModel;
  final String storeType;

  // list caches (home / all-store screens)
  final List<Store>? popularStoreList;
  final List<Store>? latestStoreList;
  final List<Store>? featuredStoreList;
  final List<Store>? visitAgainStoreList;
  final List<Store>? recommendedStoreList;

  // current store detail (store screen)
  final Store? store;
  final bool isLoading;

  // items inside the store screen
  final ItemModel? storeItemModel;
  final ItemModel? storeSearchItemModel;
  final int categoryIndex;
  final List<CategoryModel>? categoryList;
  final String type;
  final String searchType;
  final String searchText;
  final bool isSearching;

  // recommended / suggested
  final RecommendedItemModel? recommendedItemModel;
  final CartSuggestItemModel? cartSuggestItemModel;
  final List<StoreBannerModel>? storeBanners;

  // UI state
  final bool showFavButton;
  final bool currentState; // animation expand/collapse flag
  final List<XFile> pickedPrescriptions;

  final String? errorMessage;

  const StoreState({
    this.status = StoreStatus.initial,
    this.storeModel,
    this.storeType = 'all',
    this.popularStoreList,
    this.latestStoreList,
    this.featuredStoreList,
    this.visitAgainStoreList,
    this.recommendedStoreList,
    this.store,
    this.isLoading = false,
    this.storeItemModel,
    this.storeSearchItemModel,
    this.categoryIndex = 0,
    this.categoryList,
    this.type = 'all',
    this.searchType = 'all',
    this.searchText = '',
    this.isSearching = false,
    this.recommendedItemModel,
    this.cartSuggestItemModel,
    this.storeBanners,
    this.showFavButton = true,
    this.currentState = true,
    this.pickedPrescriptions = const [],
    this.errorMessage,
  });

  StoreState copyWith({
    StoreStatus? status,
    StoreModel? storeModel,
    String? storeType,
    List<Store>? popularStoreList,
    List<Store>? latestStoreList,
    List<Store>? featuredStoreList,
    List<Store>? visitAgainStoreList,
    List<Store>? recommendedStoreList,
    Store? store,
    bool? isLoading,
    ItemModel? storeItemModel,
    ItemModel? storeSearchItemModel,
    int? categoryIndex,
    List<CategoryModel>? categoryList,
    String? type,
    String? searchType,
    String? searchText,
    bool? isSearching,
    RecommendedItemModel? recommendedItemModel,
    CartSuggestItemModel? cartSuggestItemModel,
    List<StoreBannerModel>? storeBanners,
    bool? showFavButton,
    bool? currentState,
    List<XFile>? pickedPrescriptions,
    String? errorMessage,
    // nullable-clear helpers
    bool clearStore = false,
    bool clearStoreModel = false,
    bool clearStoreItemModel = false,
    bool clearStoreSearchItemModel = false,
    bool clearCategoryList = false,
    bool clearError = false,
  }) {
    return StoreState(
      status: status ?? this.status,
      storeModel: clearStoreModel ? null : (storeModel ?? this.storeModel),
      storeType: storeType ?? this.storeType,
      popularStoreList: popularStoreList ?? this.popularStoreList,
      latestStoreList: latestStoreList ?? this.latestStoreList,
      featuredStoreList: featuredStoreList ?? this.featuredStoreList,
      visitAgainStoreList: visitAgainStoreList ?? this.visitAgainStoreList,
      recommendedStoreList: recommendedStoreList ?? this.recommendedStoreList,
      store: clearStore ? null : (store ?? this.store),
      isLoading: isLoading ?? this.isLoading,
      storeItemModel: clearStoreItemModel
          ? null
          : (storeItemModel ?? this.storeItemModel),
      storeSearchItemModel: clearStoreSearchItemModel
          ? null
          : (storeSearchItemModel ?? this.storeSearchItemModel),
      categoryIndex: categoryIndex ?? this.categoryIndex,
      categoryList: clearCategoryList
          ? null
          : (categoryList ?? this.categoryList),
      type: type ?? this.type,
      searchType: searchType ?? this.searchType,
      searchText: searchText ?? this.searchText,
      isSearching: isSearching ?? this.isSearching,
      recommendedItemModel: recommendedItemModel ?? this.recommendedItemModel,
      cartSuggestItemModel: cartSuggestItemModel ?? this.cartSuggestItemModel,
      storeBanners: storeBanners ?? this.storeBanners,
      showFavButton: showFavButton ?? this.showFavButton,
      currentState: currentState ?? this.currentState,
      pickedPrescriptions: pickedPrescriptions ?? this.pickedPrescriptions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    storeModel,
    storeType,
    popularStoreList,
    latestStoreList,
    featuredStoreList,
    visitAgainStoreList,
    recommendedStoreList,
    store,
    isLoading,
    storeItemModel,
    storeSearchItemModel,
    categoryIndex,
    categoryList,
    type,
    searchType,
    searchText,
    isSearching,
    recommendedItemModel,
    cartSuggestItemModel,
    storeBanners,
    showFavButton,
    currentState,
    pickedPrescriptions,
    errorMessage,
  ];
}
