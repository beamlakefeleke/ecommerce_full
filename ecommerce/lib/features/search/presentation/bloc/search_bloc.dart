import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/search/domain/helpers/search_sort_helper.dart';
import 'package:ecommerce/features/search/domain/repositories/search_repository.dart';
import 'package:ecommerce/features/search/domain/usecases/search_usecases.dart';
import 'package:ecommerce/features/search/presentation/bloc/search_event.dart';
import 'package:ecommerce/features/search/presentation/bloc/search_state.dart';

/// Screen-scoped bloc for the search feature. Provided per-screen via
/// [BlocProvider]; not cross-cutting. All filter/sort operations are
/// synchronous state mutations; network calls are async.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchItemsUseCase searchItems;
  final SearchStoresUseCase searchStores;
  final GetSuggestedItemsUseCase getSuggestedItems;
  final SearchRepository repository;

  SearchBloc({
    required this.searchItems,
    required this.searchStores,
    required this.getSuggestedItems,
    required this.repository,
  }) : super(const SearchState()) {
    on<SearchInitialized>(_onInitialized);
    on<SearchModeReset>(_onModeReset);
    on<SearchSubmitted>(_onSubmitted);
    on<SearchTextChanged>(_onTextChanged);
    on<SearchHomeTextCleared>(_onHomeTextCleared);
    on<SearchStoreToggled>(_onStoreToggled);
    on<SearchHistoryItemRemoved>(_onHistoryItemRemoved);
    on<SearchHistoryCleared>(_onHistoryCleared);
    on<SearchPriceRangeSet>(_onPriceRangeSet);
    on<SearchItemRatingSet>(_onItemRatingSet);
    on<SearchStoreRatingSet>(_onStoreRatingSet);
    on<SearchItemSortIndexSet>(_onItemSortIndexSet);
    on<SearchStoreSortIndexSet>(_onStoreSortIndexSet);
    on<SearchVegToggled>(_onVegToggled);
    on<SearchNonVegToggled>(_onNonVegToggled);
    on<SearchStoreVegToggled>(_onStoreVegToggled);
    on<SearchStoreNonVegToggled>(_onStoreNonVegToggled);
    on<SearchAvailableItemsToggled>(_onAvailableItemsToggled);
    on<SearchDiscountedItemsToggled>(_onDiscountedItemsToggled);
    on<SearchAvailableStoreToggled>(_onAvailableStoreToggled);
    on<SearchDiscountedStoreToggled>(_onDiscountedStoreToggled);
    on<SearchItemFilterReset>(_onItemFilterReset);
    on<SearchStoreFilterReset>(_onStoreFilterReset);
    on<SearchFiltersApplied>(_onFiltersApplied);
  }

  Future<void> _onInitialized(
    SearchInitialized event,
    Emitter<SearchState> emit,
  ) async {
    // Load history synchronously.
    final history = repository.getSearchHistory();
    emit(state.copyWith(historyList: history));

    // Load suggested items for logged-in users.
    if (event.isLoggedIn) {
      final result = await getSuggestedItems(const NoParams());
      result.fold((_) {}, (list) => emit(state.copyWith(suggestedItemList: list)));
    }

    // Execute initial query if provided (e.g. from home screen).
    if (event.initialQuery != null && event.initialQuery!.isNotEmpty) {
      add(SearchSubmitted(event.initialQuery!, fromHome: true));
    }
  }

  void _onModeReset(SearchModeReset event, Emitter<SearchState> emit) {
    emit(
      state.copyWith(
        isSearchMode: true,
        searchText: '',
        itemResultText: '',
        storeResultText: '',
        clearAllItemList: true,
        clearAllStoreList: true,
        clearSearchItemList: true,
        clearSearchStoreList: true,
        sortIndex: -1,
        storeSortIndex: -1,
        isDiscountedItems: false,
        isDiscountedStore: false,
        isAvailableItems: false,
        isAvailableStore: false,
        veg: false,
        storeVeg: false,
        nonVeg: false,
        storeNonVeg: false,
        rating: -1,
        storeRating: -1,
        upperValue: 0,
        lowerValue: 0,
        isStore: false,
      ),
    );
  }

  Future<void> _onSubmitted(
    SearchSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query;
    // Dedup: skip if the same query produced the current results.
    final alreadyLoaded = state.isStore
        ? (query == state.storeResultText)
        : (query == state.itemResultText && !event.fromHome);
    if (query.isEmpty || alreadyLoaded) return;

    // Update history.
    final history = List<String>.from(state.historyList);
    if (!history.contains(query)) history.insert(0, query);
    await repository.saveSearchHistory(history);

    emit(
      state.copyWith(
        searchText: query,
        searchHomeText: query,
        isSearchMode: false,
        historyList: history,
        rating: -1,
        storeRating: -1,
        upperValue: 0,
        lowerValue: 0,
        clearAllItemList: !state.isStore,
        clearAllStoreList: state.isStore,
        clearSearchItemList: !state.isStore,
        clearSearchStoreList: state.isStore,
        status: SearchStatus.loading,
      ),
    );

    if (state.isStore) {
      final result = await searchStores(query);
      result.fold(
        (f) => emit(
          state.copyWith(
            status: SearchStatus.error,
            errorMessage: f.message,
          ),
        ),
        (stores) => emit(
          state.copyWith(
            status: SearchStatus.loaded,
            storeResultText: query,
            allStoreList: stores,
            searchStoreList: stores,
          ),
        ),
      );
    } else {
      final result = await searchItems(query);
      result.fold(
        (f) => emit(
          state.copyWith(
            status: SearchStatus.error,
            errorMessage: f.message,
          ),
        ),
        (items) => emit(
          state.copyWith(
            status: SearchStatus.loaded,
            itemResultText: query,
            allItemList: items,
            searchItemList: items,
          ),
        ),
      );
    }
  }

  void _onTextChanged(SearchTextChanged event, Emitter<SearchState> emit) {
    emit(state.copyWith(searchText: event.text));
  }

  void _onHomeTextCleared(
      SearchHomeTextCleared event, Emitter<SearchState> emit) {
    emit(state.copyWith(searchHomeText: ''));
  }

  void _onStoreToggled(SearchStoreToggled event, Emitter<SearchState> emit) {
    emit(state.copyWith(isStore: event.isStore));
  }

  Future<void> _onHistoryItemRemoved(
    SearchHistoryItemRemoved event,
    Emitter<SearchState> emit,
  ) async {
    final history = List<String>.from(state.historyList)..removeAt(event.index);
    await repository.saveSearchHistory(history);
    emit(state.copyWith(historyList: history));
  }

  Future<void> _onHistoryCleared(
    SearchHistoryCleared event,
    Emitter<SearchState> emit,
  ) async {
    await repository.clearSearchHistory();
    emit(state.copyWith(historyList: []));
  }

  void _onPriceRangeSet(SearchPriceRangeSet event, Emitter<SearchState> emit) {
    emit(state.copyWith(lowerValue: event.lower, upperValue: event.upper));
  }

  void _onItemRatingSet(SearchItemRatingSet event, Emitter<SearchState> emit) {
    emit(state.copyWith(rating: event.rating));
  }

  void _onStoreRatingSet(
      SearchStoreRatingSet event, Emitter<SearchState> emit) {
    emit(state.copyWith(storeRating: event.rating));
  }

  void _onItemSortIndexSet(
      SearchItemSortIndexSet event, Emitter<SearchState> emit) {
    emit(state.copyWith(sortIndex: event.index));
  }

  void _onStoreSortIndexSet(
      SearchStoreSortIndexSet event, Emitter<SearchState> emit) {
    emit(state.copyWith(storeSortIndex: event.index));
  }

  void _onVegToggled(SearchVegToggled event, Emitter<SearchState> emit) {
    emit(state.copyWith(veg: !state.veg));
  }

  void _onNonVegToggled(SearchNonVegToggled event, Emitter<SearchState> emit) {
    emit(state.copyWith(nonVeg: !state.nonVeg));
  }

  void _onStoreVegToggled(
      SearchStoreVegToggled event, Emitter<SearchState> emit) {
    emit(state.copyWith(storeVeg: !state.storeVeg));
  }

  void _onStoreNonVegToggled(
      SearchStoreNonVegToggled event, Emitter<SearchState> emit) {
    emit(state.copyWith(storeNonVeg: !state.storeNonVeg));
  }

  void _onAvailableItemsToggled(
      SearchAvailableItemsToggled event, Emitter<SearchState> emit) {
    emit(state.copyWith(isAvailableItems: !state.isAvailableItems));
  }

  void _onDiscountedItemsToggled(
      SearchDiscountedItemsToggled event, Emitter<SearchState> emit) {
    emit(state.copyWith(isDiscountedItems: !state.isDiscountedItems));
  }

  void _onAvailableStoreToggled(
      SearchAvailableStoreToggled event, Emitter<SearchState> emit) {
    emit(state.copyWith(isAvailableStore: !state.isAvailableStore));
  }

  void _onDiscountedStoreToggled(
      SearchDiscountedStoreToggled event, Emitter<SearchState> emit) {
    emit(state.copyWith(isDiscountedStore: !state.isDiscountedStore));
  }

  void _onItemFilterReset(
      SearchItemFilterReset event, Emitter<SearchState> emit) {
    emit(
      state.copyWith(
        rating: -1,
        upperValue: 0,
        lowerValue: 0,
        isAvailableItems: false,
        isDiscountedItems: false,
        veg: false,
        nonVeg: false,
        sortIndex: -1,
      ),
    );
  }

  void _onStoreFilterReset(
      SearchStoreFilterReset event, Emitter<SearchState> emit) {
    emit(
      state.copyWith(
        storeRating: -1,
        isAvailableStore: false,
        isDiscountedStore: false,
        storeVeg: false,
        storeNonVeg: false,
        storeSortIndex: -1,
      ),
    );
  }

  /// Re-apply the active filter knobs to the buffered full result lists.
  void _onFiltersApplied(
      SearchFiltersApplied event, Emitter<SearchState> emit) {
    if (state.isStore) {
      if (state.allStoreList == null) return;
      final filtered = SearchSortHelper.sortStores(
        all: state.allStoreList!,
        rating: state.storeRating,
        veg: state.storeVeg,
        nonVeg: state.storeNonVeg,
        isAvailable: state.isAvailableStore,
        isDiscounted: state.isDiscountedStore,
        sortIndex: state.storeSortIndex,
      );
      emit(state.copyWith(searchStoreList: filtered));
    } else {
      if (state.allItemList == null) return;
      final filtered = SearchSortHelper.sortItems(
        all: state.allItemList!,
        lowerValue: state.lowerValue,
        upperValue: state.upperValue,
        rating: state.rating,
        veg: state.veg,
        nonVeg: state.nonVeg,
        isAvailable: state.isAvailableItems,
        isDiscounted: state.isDiscountedItems,
        sortIndex: state.sortIndex,
      );
      emit(state.copyWith(searchItemList: filtered));
    }
  }
}
