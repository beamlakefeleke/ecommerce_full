import 'package:equatable/equatable.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Reset to search-mode (clears results + all filters). Called on init and
/// on the back-button when already showing results.
class SearchModeReset extends SearchEvent {
  const SearchModeReset();
}

/// Load history + suggested items on screen open.
class SearchInitialized extends SearchEvent {
  final String? initialQuery;
  final bool isLoggedIn;

  const SearchInitialized({this.initialQuery, required this.isLoggedIn});

  @override
  List<Object?> get props => [initialQuery, isLoggedIn];
}

/// Execute a search for [query].
class SearchSubmitted extends SearchEvent {
  final String query;
  final bool fromHome;

  const SearchSubmitted(this.query, {this.fromHome = false});

  @override
  List<Object?> get props => [query, fromHome];
}

class SearchTextChanged extends SearchEvent {
  final String text;
  const SearchTextChanged(this.text);

  @override
  List<Object?> get props => [text];
}

class SearchHomeTextCleared extends SearchEvent {
  const SearchHomeTextCleared();
}

/// Switch between item-search (isStore=false) and store-search (isStore=true).
class SearchStoreToggled extends SearchEvent {
  final bool isStore;
  const SearchStoreToggled(this.isStore);

  @override
  List<Object?> get props => [isStore];
}

class SearchHistoryItemRemoved extends SearchEvent {
  final int index;
  const SearchHistoryItemRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

class SearchHistoryCleared extends SearchEvent {
  const SearchHistoryCleared();
}

// --- Filter / sort events ---

class SearchPriceRangeSet extends SearchEvent {
  final double lower;
  final double upper;
  const SearchPriceRangeSet(this.lower, this.upper);

  @override
  List<Object?> get props => [lower, upper];
}

class SearchItemRatingSet extends SearchEvent {
  final int rating;
  const SearchItemRatingSet(this.rating);

  @override
  List<Object?> get props => [rating];
}

class SearchStoreRatingSet extends SearchEvent {
  final int rating;
  const SearchStoreRatingSet(this.rating);

  @override
  List<Object?> get props => [rating];
}

class SearchItemSortIndexSet extends SearchEvent {
  final int index;
  const SearchItemSortIndexSet(this.index);

  @override
  List<Object?> get props => [index];
}

class SearchStoreSortIndexSet extends SearchEvent {
  final int index;
  const SearchStoreSortIndexSet(this.index);

  @override
  List<Object?> get props => [index];
}

class SearchVegToggled extends SearchEvent {
  const SearchVegToggled();
}

class SearchNonVegToggled extends SearchEvent {
  const SearchNonVegToggled();
}

class SearchStoreVegToggled extends SearchEvent {
  const SearchStoreVegToggled();
}

class SearchStoreNonVegToggled extends SearchEvent {
  const SearchStoreNonVegToggled();
}

class SearchAvailableItemsToggled extends SearchEvent {
  const SearchAvailableItemsToggled();
}

class SearchDiscountedItemsToggled extends SearchEvent {
  const SearchDiscountedItemsToggled();
}

class SearchAvailableStoreToggled extends SearchEvent {
  const SearchAvailableStoreToggled();
}

class SearchDiscountedStoreToggled extends SearchEvent {
  const SearchDiscountedStoreToggled();
}

class SearchItemFilterReset extends SearchEvent {
  const SearchItemFilterReset();
}

class SearchStoreFilterReset extends SearchEvent {
  const SearchStoreFilterReset();
}

/// Re-apply active filters to the buffered full result lists.
class SearchFiltersApplied extends SearchEvent {
  const SearchFiltersApplied();
}
