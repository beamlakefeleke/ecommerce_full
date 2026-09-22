import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';

enum FavouriteStatus { initial, loading, success, failure }

class FavouriteState extends Equatable {
  final FavouriteStatus status;
  final List<Item?> wishItemList;
  final List<Store?> wishStoreList;
  final List<int?> wishItemIdList;
  final List<int?> wishStoreIdList;
  final bool isRemoving;
  final String? errorMessage;

  const FavouriteState({
    this.status = FavouriteStatus.initial,
    this.wishItemList = const [],
    this.wishStoreList = const [],
    this.wishItemIdList = const [],
    this.wishStoreIdList = const [],
    this.isRemoving = false,
    this.errorMessage,
  });

  FavouriteState copyWith({
    FavouriteStatus? status,
    List<Item?>? wishItemList,
    List<Store?>? wishStoreList,
    List<int?>? wishItemIdList,
    List<int?>? wishStoreIdList,
    bool? isRemoving,
    String? errorMessage,
  }) {
    return FavouriteState(
      status: status ?? this.status,
      wishItemList: wishItemList ?? this.wishItemList,
      wishStoreList: wishStoreList ?? this.wishStoreList,
      wishItemIdList: wishItemIdList ?? this.wishItemIdList,
      wishStoreIdList: wishStoreIdList ?? this.wishStoreIdList,
      isRemoving: isRemoving ?? this.isRemoving,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    wishItemList,
    wishStoreList,
    wishItemIdList,
    wishStoreIdList,
    isRemoving,
    errorMessage,
  ];
}
