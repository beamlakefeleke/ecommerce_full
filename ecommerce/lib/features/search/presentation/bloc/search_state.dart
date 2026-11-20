import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';

enum SearchStatus { initial, loading, loaded, error }

/// Single immutable state. All filter/sort knobs + both result lists coexist
/// (rule 6 — data survives across filter/sort actions).
class SearchState extends Equatable {
  // Search mode: true = showing history/suggestions; false = showing results.
  final bool isSearchMode;

  // Which tab is active.
  final bool isStore;

  // The text shown in the search field.
  final String searchText;

  // The text used for the last web-bar search.
  final String searchHomeText;

  // The query whose results are currently displayed (for dedup).
  final String itemResultText;
  final String storeResultText;

  final SearchStatus status;

  // Full (unfiltered) results returned by the API.
  final List<Item>? allItemList;
  final List<Store>? allStoreList;

  // Filtered/sorted views of the above.
  final List<Item>? searchItemList;
  final List<Store>? searchStoreList;

  // Suggested items (shown in search mode when logged in).
  final List<Item>? suggestedItemList;

  // History (shown in search mode).
  final List<String> historyList;

  // --- Item filter state ---
  final double lowerValue;
  final double upperValue;
  final int rating;
  final bool veg;
  final bool nonVeg;
  final bool isAvailableItems;
  final bool isDiscountedItems;
  final int sortIndex;

  // --- Store filter state ---
  final int storeRating;
  final bool storeVeg;
  final bool storeNonVeg;
  final bool isAvailableStore;
  final bool isDiscountedStore;
  final int storeSortIndex;

  final String? errorMessage;

  const SearchState({
    this.isSearchMode = true,
    this.isStore = false,
    this.searchText = '',
    this.searchHomeText = '',
    this.itemResultText = '',
    this.storeResultText = '',
    this.status = SearchStatus.initial,
    this.allItemList,
    this.allStoreList,
    this.searchItemList,
    this.searchStoreList,
    this.suggestedItemList,
    this.historyList = const [],
    this.lowerValue = 0,
    this.upperValue = 0,
    this.rating = -1,
    this.veg = false,
    this.nonVeg = false,
    this.isAvailableItems = false,
    this.isDiscountedItems = false,
    this.sortIndex = -1,
    this.storeRating = -1,
    this.storeVeg = false,
    this.storeNonVeg = false,
    this.isAvailableStore = false,
    this.isDiscountedStore = false,
    this.storeSortIndex = -1,
    this.errorMessage,
  });

  SearchState copyWith({
    bool? isSearchMode,
    bool? isStore,
    String? searchText,
    String? searchHomeText,
    String? itemResultText,
    String? storeResultText,
    SearchStatus? status,
    List<Item>? allItemList,
    bool clearAllItemList = false,
    List<Store>? allStoreList,
    bool clearAllStoreList = false,
    List<Item>? searchItemList,
    bool clearSearchItemList = false,
    List<Store>? searchStoreList,
    bool clearSearchStoreList = false,
    List<Item>? suggestedItemList,
    List<String>? historyList,
    double? lowerValue,
    double? upperValue,
    int? rating,
    bool? veg,
    bool? nonVeg,
    bool? isAvailableItems,
    bool? isDiscountedItems,
    int? sortIndex,
    int? storeRating,
    bool? storeVeg,
    bool? storeNonVeg,
    bool? isAvailableStore,
    bool? isDiscountedStore,
    int? storeSortIndex,
    String? errorMessage,
  }) {
    return SearchState(
      isSearchMode: isSearchMode ?? this.isSearchMode,
      isStore: isStore ?? this.isStore,
      searchText: searchText ?? this.searchText,
      searchHomeText: searchHomeText ?? this.searchHomeText,
      itemResultText: itemResultText ?? this.itemResultText,
      storeResultText: storeResultText ?? this.storeResultText,
      status: status ?? this.status,
      allItemList: clearAllItemList ? null : (allItemList ?? this.allItemList),
      allStoreList:
          clearAllStoreList ? null : (allStoreList ?? this.allStoreList),
      searchItemList: clearSearchItemList
          ? null
          : (searchItemList ?? this.searchItemList),
      searchStoreList: clearSearchStoreList
          ? null
          : (searchStoreList ?? this.searchStoreList),
      suggestedItemList: suggestedItemList ?? this.suggestedItemList,
      historyList: historyList ?? this.historyList,
      lowerValue: lowerValue ?? this.lowerValue,
      upperValue: upperValue ?? this.upperValue,
      rating: rating ?? this.rating,
      veg: veg ?? this.veg,
      nonVeg: nonVeg ?? this.nonVeg,
      isAvailableItems: isAvailableItems ?? this.isAvailableItems,
      isDiscountedItems: isDiscountedItems ?? this.isDiscountedItems,
      sortIndex: sortIndex ?? this.sortIndex,
      storeRating: storeRating ?? this.storeRating,
      storeVeg: storeVeg ?? this.storeVeg,
      storeNonVeg: storeNonVeg ?? this.storeNonVeg,
      isAvailableStore: isAvailableStore ?? this.isAvailableStore,
      isDiscountedStore: isDiscountedStore ?? this.isDiscountedStore,
      storeSortIndex: storeSortIndex ?? this.storeSortIndex,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isSearchMode, isStore, searchText, searchHomeText,
    itemResultText, storeResultText, status,
    allItemList, allStoreList, searchItemList, searchStoreList,
    suggestedItemList, historyList,
    lowerValue, upperValue, rating, veg, nonVeg,
    isAvailableItems, isDiscountedItems, sortIndex,
    storeRating, storeVeg, storeNonVeg,
    isAvailableStore, isDiscountedStore, storeSortIndex,
    errorMessage,
  ];
}
