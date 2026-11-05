part of 'favourite_bloc.dart';

class FavouriteState extends Equatable {
  /// null = not yet loaded (UI shows a spinner).
  final List<Item?>? wishItemList;
  final List<Store?>? wishStoreList;
  final List<int?> wishItemIdList;
  final List<int?> wishStoreIdList;
  final bool isRemoving;

  /// Transient message to surface in a snackbar; cleared on the next action.
  final String? message;
  final bool messageIsError;

  const FavouriteState({
    this.wishItemList,
    this.wishStoreList,
    this.wishItemIdList = const [],
    this.wishStoreIdList = const [],
    this.isRemoving = false,
    this.message,
    this.messageIsError = true,
  });

  FavouriteState copyWith({
    List<Item?>? wishItemList,
    List<Store?>? wishStoreList,
    List<int?>? wishItemIdList,
    List<int?>? wishStoreIdList,
    bool? isRemoving,
    String? message,
    bool? messageIsError,
    bool clearItemList = false,
    bool clearStoreList = false,
    bool clearMessage = false,
  }) {
    return FavouriteState(
      wishItemList: clearItemList ? null : (wishItemList ?? this.wishItemList),
      wishStoreList: clearStoreList
          ? null
          : (wishStoreList ?? this.wishStoreList),
      wishItemIdList: wishItemIdList ?? this.wishItemIdList,
      wishStoreIdList: wishStoreIdList ?? this.wishStoreIdList,
      isRemoving: isRemoving ?? this.isRemoving,
      message: clearMessage ? null : (message ?? this.message),
      messageIsError: messageIsError ?? this.messageIsError,
    );
  }

  @override
  List<Object?> get props => [
    wishItemList,
    wishStoreList,
    wishItemIdList,
    wishStoreIdList,
    isRemoving,
    message,
    messageIsError,
  ];
}
