import 'package:equatable/equatable.dart';

sealed class StoreEvent extends Equatable {
  const StoreEvent();

  @override
  List<Object?> get props => [];
}

class StoreListRequested extends StoreEvent {
  final int offset;
  final String filterBy;
  const StoreListRequested({required this.offset, required this.filterBy});

  @override
  List<Object?> get props => [offset, filterBy];
}

class PopularStoreListRequested extends StoreEvent {
  final String type;
  final bool reload;
  final bool notify;
  const PopularStoreListRequested({
    required this.type,
    this.reload = false,
    this.notify = false,
  });

  @override
  List<Object?> get props => [type, reload, notify];
}

class LatestStoreListRequested extends StoreEvent {
  final String type;
  final bool reload;
  final bool notify;
  const LatestStoreListRequested({
    required this.type,
    this.reload = false,
    this.notify = false,
  });

  @override
  List<Object?> get props => [type, reload, notify];
}

class FeaturedStoreListRequested extends StoreEvent {
  const FeaturedStoreListRequested();
}

class VisitAgainStoreListRequested extends StoreEvent {
  final bool fromModule;
  const VisitAgainStoreListRequested({this.fromModule = false});

  @override
  List<Object?> get props => [fromModule];
}

class RecommendedStoreListRequested extends StoreEvent {
  const RecommendedStoreListRequested();
}

class StoreDetailsRequested extends StoreEvent {
  final String storeID;
  final bool fromModule;
  final bool fromCart;
  final String slug;

  const StoreDetailsRequested({
    required this.storeID,
    this.fromModule = false,
    this.fromCart = false,
    this.slug = '',
  });

  @override
  List<Object?> get props => [storeID, fromModule, fromCart, slug];
}

class StoreItemListRequested extends StoreEvent {
  final int? storeID;
  final int offset;
  final String type;
  final bool notify;

  const StoreItemListRequested({
    required this.storeID,
    required this.offset,
    required this.type,
    this.notify = false,
  });

  @override
  List<Object?> get props => [storeID, offset, type, notify];
}

class StoreSearchItemListRequested extends StoreEvent {
  final String searchText;
  final String? storeID;
  final int offset;
  final String type;

  const StoreSearchItemListRequested({
    required this.searchText,
    this.storeID,
    required this.offset,
    required this.type,
  });

  @override
  List<Object?> get props => [searchText, storeID, offset, type];
}

class StoreRecommendedItemListRequested extends StoreEvent {
  final int? storeId;
  final bool reload;
  const StoreRecommendedItemListRequested({this.storeId, this.reload = false});

  @override
  List<Object?> get props => [storeId, reload];
}

class CartStoreSuggestedItemListRequested extends StoreEvent {
  final int? storeId;
  const CartStoreSuggestedItemListRequested({this.storeId});

  @override
  List<Object?> get props => [storeId];
}

class StoreBannerListRequested extends StoreEvent {
  final int? storeId;
  const StoreBannerListRequested({this.storeId});

  @override
  List<Object?> get props => [storeId];
}

class StoreCategoryIndexChanged extends StoreEvent {
  final int index;
  final bool itemSearching;
  const StoreCategoryIndexChanged(this.index, {this.itemSearching = false});

  @override
  List<Object?> get props => [index, itemSearching];
}

class StoreSearchStatusToggled extends StoreEvent {
  const StoreSearchStatusToggled();
}

class StoreSearchDataInitialized extends StoreEvent {
  const StoreSearchDataInitialized();
}

class StorePrescriptionImagePicked extends StoreEvent {
  final bool isRemove;
  final bool isCamera;
  const StorePrescriptionImagePicked({
    required this.isRemove,
    required this.isCamera,
  });

  @override
  List<Object?> get props => [isRemove, isCamera];
}

class StorePrescriptionImageRemoved extends StoreEvent {
  final int index;
  const StorePrescriptionImageRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

class StoreFavVisibilityChanged extends StoreEvent {
  const StoreFavVisibilityChanged();
}

class StoreAnimationHidden extends StoreEvent {
  const StoreAnimationHidden();
}

class StoreButtonAnimationShown extends StoreEvent {
  const StoreButtonAnimationShown();
}

class StoreTypeChanged extends StoreEvent {
  final String storeType;
  const StoreTypeChanged(this.storeType);

  @override
  List<Object?> get props => [storeType];
}
