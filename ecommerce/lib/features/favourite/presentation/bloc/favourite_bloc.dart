import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/favourite/domain/usecases/add_favourite_usecase.dart';
import 'package:ecommerce/features/favourite/domain/usecases/get_favourite_list_usecase.dart';
import 'package:ecommerce/features/favourite/domain/usecases/remove_favourite_usecase.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/helper/address_helper.dart';

part 'favourite_event.dart';
part 'favourite_state.dart';

class FavouriteBloc extends Bloc<FavouriteEvent, FavouriteState> {
  final GetFavouriteListUseCase getFavouriteListUseCase;
  final AddFavouriteUseCase addFavouriteUseCase;
  final RemoveFavouriteUseCase removeFavouriteUseCase;

  FavouriteBloc({
    required this.getFavouriteListUseCase,
    required this.addFavouriteUseCase,
    required this.removeFavouriteUseCase,
  }) : super(const FavouriteState()) {
    on<FavouriteListRequested>(_onListRequested);
    on<FavouriteAdded>(_onAdded);
    on<FavouriteRemoved>(_onRemoved);
    on<FavouriteCleared>(_onCleared);
  }

  Future<void> _onListRequested(
    FavouriteListRequested event,
    Emitter<FavouriteState> emit,
  ) async {
    emit(state.copyWith(clearItemList: true, clearStoreList: true));
    final result = await getFavouriteListUseCase(const NoParams());
    result.fold((failure) {}, (body) {
      final List<Item?> wishItemList = [];
      final List<Store?> wishStoreList = [];
      final List<int?> wishItemIdList = [];
      final List<int?> wishStoreIdList = [];

      if (body['item'] != null) {
        for (final item in body['item']) {
          if (item['module_type'] == null ||
              !Get.find<SplashController>()
                  .getModuleConfig(item['module_type'])
                  .newVariation! ||
              item['variations'] == null ||
              item['variations'].isEmpty ||
              (item['food_variations'] != null &&
                  item['food_variations'].isNotEmpty)) {
            final Item i = Item.fromJson(item);
            if (Get.find<SplashController>().module == null) {
              wishItemList.addAll(_wishItemList(i));
              wishItemIdList.addAll(_wishItemIdList(i));
            } else {
              wishItemList.add(i);
              wishItemIdList.add(i.id);
            }
          }
        }
      }

      if (body['store'] != null) {
        for (final store in body['store']) {
          if (Get.find<SplashController>().module == null) {
            wishStoreList.addAll(_wishStoreList(store));
            wishStoreIdList.addAll(_wishStoreIdList(store));
          } else {
            Store? s;
            try {
              s = Store.fromJson(store);
            } catch (e) {
              debugPrint('exception create in store list create : $e');
            }
            if (s != null &&
                Get.find<SplashController>().module!.id == s.moduleId) {
              wishStoreList.add(s);
              wishStoreIdList.add(s.id);
            }
          }
        }
      }

      emit(
        state.copyWith(
          wishItemList: wishItemList,
          wishStoreList: wishStoreList,
          wishItemIdList: wishItemIdList,
          wishStoreIdList: wishStoreIdList,
        ),
      );
    });
  }

  Future<void> _onAdded(
    FavouriteAdded event,
    Emitter<FavouriteState> emit,
  ) async {
    // Optimistically add.
    final List<Item?> items = List.of(state.wishItemList ?? []);
    final List<Store?> stores = List.of(state.wishStoreList ?? []);
    final List<int?> itemIds = List.of(state.wishItemIdList);
    final List<int?> storeIds = List.of(state.wishStoreIdList);

    if (event.isStore) {
      storeIds.add(event.store!.id);
      stores.add(event.store);
    } else {
      items.add(event.product);
      itemIds.add(event.product!.id);
    }
    emit(
      state.copyWith(
        wishItemList: items,
        wishStoreList: stores,
        wishItemIdList: itemIds,
        wishStoreIdList: storeIds,
        clearMessage: true,
      ),
    );

    final result = await addFavouriteUseCase(
      FavouriteParams(
        id: event.isStore ? event.store!.id : event.product!.id,
        isStore: event.isStore,
      ),
    );
    result.fold(
      (failure) {
        // Roll back the id list on failure (matches legacy behaviour).
        final List<int?> rbItemIds = List.of(state.wishItemIdList);
        final List<int?> rbStoreIds = List.of(state.wishStoreIdList);
        if (event.isStore) {
          rbStoreIds.remove(event.store!.id);
        } else {
          rbItemIds.remove(event.product!.id);
        }
        emit(
          state.copyWith(
            wishItemIdList: rbItemIds,
            wishStoreIdList: rbStoreIds,
            message: failure.message,
            messageIsError: true,
          ),
        );
      },
      (message) =>
          emit(state.copyWith(message: message, messageIsError: false)),
    );
  }

  Future<void> _onRemoved(
    FavouriteRemoved event,
    Emitter<FavouriteState> emit,
  ) async {
    emit(state.copyWith(isRemoving: true, clearMessage: true));

    final List<Item?> items = List.of(state.wishItemList ?? []);
    final List<Store?> stores = List.of(state.wishStoreList ?? []);
    final List<int?> itemIds = List.of(state.wishItemIdList);
    final List<int?> storeIds = List.of(state.wishStoreIdList);

    int idIndex = -1;
    int? storeId, itemId;
    Store? store;
    Item? item;
    if (event.isStore) {
      idIndex = storeIds.indexOf(event.id);
      if (idIndex != -1) {
        storeId = event.id;
        storeIds.removeAt(idIndex);
        store = stores[idIndex];
        stores.removeAt(idIndex);
      }
    } else {
      idIndex = itemIds.indexOf(event.id);
      if (idIndex != -1) {
        itemId = event.id;
        itemIds.removeAt(idIndex);
        item = items[idIndex];
        items.removeAt(idIndex);
      }
    }
    emit(
      state.copyWith(
        wishItemList: items,
        wishStoreList: stores,
        wishItemIdList: itemIds,
        wishStoreIdList: storeIds,
      ),
    );

    final result = await removeFavouriteUseCase(
      FavouriteParams(id: event.id, isStore: event.isStore),
    );
    result.fold(
      (failure) {
        // Roll back.
        final List<Item?> rbItems = List.of(state.wishItemList ?? []);
        final List<Store?> rbStores = List.of(state.wishStoreList ?? []);
        final List<int?> rbItemIds = List.of(state.wishItemIdList);
        final List<int?> rbStoreIds = List.of(state.wishStoreIdList);
        if (event.isStore) {
          rbStoreIds.add(storeId);
          rbStores.add(store);
        } else {
          rbItemIds.add(itemId);
          rbItems.add(item);
        }
        emit(
          state.copyWith(
            wishItemList: rbItems,
            wishStoreList: rbStores,
            wishItemIdList: rbItemIds,
            wishStoreIdList: rbStoreIds,
            isRemoving: false,
            message: failure.message,
            messageIsError: true,
          ),
        );
      },
      (message) => emit(
        state.copyWith(
          isRemoving: false,
          message: message,
          messageIsError: false,
        ),
      ),
    );
  }

  void _onCleared(FavouriteCleared event, Emitter<FavouriteState> emit) {
    emit(state.copyWith(wishItemIdList: const [], wishStoreIdList: const []));
  }

  // ── Zone filtering (ported from the legacy FavouriteService) ───────────────

  List<Item?> _wishItemList(Item item) {
    final List<Item?> list = [];
    for (var zone in AddressHelper.getUserAddressFromSharedPref()!.zoneData!) {
      for (var module in zone.modules!) {
        if (module.id == item.moduleId && module.pivot!.zoneId == item.zoneId) {
          list.add(item);
        }
      }
    }
    return list;
  }

  List<int?> _wishItemIdList(Item item) {
    final List<int?> list = [];
    for (var zone in AddressHelper.getUserAddressFromSharedPref()!.zoneData!) {
      for (var module in zone.modules!) {
        if (module.id == item.moduleId && module.pivot!.zoneId == item.zoneId) {
          list.add(item.id);
        }
      }
    }
    return list;
  }

  List<Store?> _wishStoreList(dynamic store) {
    final List<Store?> list = [];
    final Store s = Store.fromJson(store);
    for (var zone in AddressHelper.getUserAddressFromSharedPref()!.zoneData!) {
      for (var module in zone.modules!) {
        if (module.id == s.moduleId && module.pivot!.zoneId == s.zoneId) {
          list.add(s);
        }
      }
    }
    return list;
  }

  List<int?> _wishStoreIdList(dynamic store) {
    final List<int?> list = [];
    final Store s = Store.fromJson(store);
    for (var zone in AddressHelper.getUserAddressFromSharedPref()!.zoneData!) {
      for (var module in zone.modules!) {
        if (module.id == s.moduleId && module.pivot!.zoneId == s.zoneId) {
          list.add(s.id);
        }
      }
    }
    return list;
  }
}
