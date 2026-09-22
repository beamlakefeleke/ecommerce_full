import 'package:ecommerce/features/location/domain/models/zone_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/features/favourite/domain/usecases/add_favourite_usecase.dart';
import 'package:ecommerce/features/favourite/domain/usecases/get_favourite_list_usecase.dart';
import 'package:ecommerce/features/favourite/domain/usecases/remove_favourite_usecase.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_event.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_state.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/helper/address_helper.dart';

class FavouriteBloc extends Bloc<FavouriteEvent, FavouriteState> {
  final GetFavouriteListUseCase _getFavouriteList;
  final AddFavouriteUseCase _addFavourite;
  final RemoveFavouriteUseCase _removeFavourite;

  FavouriteBloc({
    required GetFavouriteListUseCase getFavouriteListUseCase,
    required AddFavouriteUseCase addFavouriteUseCase,
    required RemoveFavouriteUseCase removeFavouriteUseCase,
  }) : _getFavouriteList = getFavouriteListUseCase,
       _addFavourite = addFavouriteUseCase,
       _removeFavourite = removeFavouriteUseCase,
       super(const FavouriteState()) {
    on<FavouriteListFetched>(_onFetched);
    on<FavouriteAdded>(_onAdded);
    on<FavouriteRemoved>(_onRemoved);
    on<FavouriteLocalCleared>(_onLocalCleared);
  }

  // ─── Fetch ────────────────────────────────────────────────────────────────

  Future<void> _onFetched(
    FavouriteListFetched event,
    Emitter<FavouriteState> emit,
  ) async {
    emit(state.copyWith(status: FavouriteStatus.loading));

    final result = await _getFavouriteList();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: FavouriteStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (body) {
        final itemList = <Item?>[];
        final itemIdList = <int?>[];
        final storeList = <Store?>[];
        final storeIdList = <int?>[];

        // Parse items
        if (body['item'] != null) {
          for (final item in body['item'] as List) {
            if (item['module_type'] == null ||
                !(Get.find<SplashController>()
                        .getModuleConfig(item['module_type'])
                        .newVariation ??
                    false) ||
                item['variations'] == null ||
                (item['variations'] as List).isEmpty ||
                (item['food_variations'] != null &&
                    (item['food_variations'] as List).isNotEmpty)) {
              final i = Item.fromJson(item);
              _addItemWithModuleFilter(i, itemList, itemIdList);
            }
          }
        }

        // Parse stores
        if (body['store'] != null) {
          for (final store in body['store'] as List) {
            _addStoreWithModuleFilter(store, storeList, storeIdList);
          }
        }

        emit(
          state.copyWith(
            status: FavouriteStatus.success,
            wishItemList: itemList,
            wishStoreList: storeList,
            wishItemIdList: itemIdList,
            wishStoreIdList: storeIdList,
          ),
        );
      },
    );
  }

  // ─── Add ──────────────────────────────────────────────────────────────────

  Future<void> _onAdded(
    FavouriteAdded event,
    Emitter<FavouriteState> emit,
  ) async {
    final id = event.isStore ? event.store!.id : event.item!.id;

    // Optimistic update
    if (event.isStore) {
      emit(
        state.copyWith(
          wishStoreIdList: [...state.wishStoreIdList, event.store!.id],
          wishStoreList: [...state.wishStoreList, event.store],
        ),
      );
    } else {
      emit(
        state.copyWith(
          wishItemIdList: [...state.wishItemIdList, event.item!.id],
          wishItemList: [...state.wishItemList, event.item],
        ),
      );
    }

    final result = await _addFavourite(id, event.isStore);
    result.fold((failure) {
      // Revert optimistic update
      if (event.isStore) {
        emit(
          state.copyWith(
            wishStoreIdList: state.wishStoreIdList
                .where((i) => i != event.store!.id)
                .toList(),
            wishStoreList: state.wishStoreList
                .where((s) => s?.id != event.store!.id)
                .toList(),
          ),
        );
      } else {
        emit(
          state.copyWith(
            wishItemIdList: state.wishItemIdList
                .where((i) => i != event.item!.id)
                .toList(),
            wishItemList: state.wishItemList
                .where((i) => i?.id != event.item!.id)
                .toList(),
          ),
        );
      }
      showCustomSnackBar(failure.message);
    }, (message) => showCustomSnackBar(message, isError: false));
  }

  // ─── Remove ───────────────────────────────────────────────────────────────

  Future<void> _onRemoved(
    FavouriteRemoved event,
    Emitter<FavouriteState> emit,
  ) async {
    emit(state.copyWith(isRemoving: true));

    // Optimistic snapshot for rollback
    final prevItemIds = List<int?>.from(state.wishItemIdList);
    final prevItems = List<Item?>.from(state.wishItemList);
    final prevStoreIds = List<int?>.from(state.wishStoreIdList);
    final prevStores = List<Store?>.from(state.wishStoreList);

    if (event.isStore) {
      emit(
        state.copyWith(
          wishStoreIdList: state.wishStoreIdList
              .where((i) => i != event.id)
              .toList(),
          wishStoreList: state.wishStoreList
              .where((s) => s?.id != event.id)
              .toList(),
        ),
      );
    } else {
      emit(
        state.copyWith(
          wishItemIdList: state.wishItemIdList
              .where((i) => i != event.id)
              .toList(),
          wishItemList: state.wishItemList
              .where((i) => i?.id != event.id)
              .toList(),
        ),
      );
    }

    final result = await _removeFavourite(event.id, event.isStore);
    result.fold(
      (failure) {
        // Rollback
        emit(
          state.copyWith(
            wishItemIdList: prevItemIds,
            wishItemList: prevItems,
            wishStoreIdList: prevStoreIds,
            wishStoreList: prevStores,
            isRemoving: false,
          ),
        );
        showCustomSnackBar(failure.message);
      },
      (message) {
        emit(state.copyWith(isRemoving: false));
        showCustomSnackBar(message, isError: false);
      },
    );
  }

  // ─── Local clear (on logout) ──────────────────────────────────────────────

  void _onLocalCleared(
    FavouriteLocalCleared event,
    Emitter<FavouriteState> emit,
  ) {
    emit(const FavouriteState());
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  void _addItemWithModuleFilter(
    Item item,
    List<Item?> itemList,
    List<int?> idList,
  ) {
    final module = Get.find<SplashController>().module;
    if (module == null) {
      // Multi-module: filter by zone + module from address data
      final address = AddressHelper.getUserAddressFromSharedPref();
      if (address != null) {
        for (final zone in address.zoneData ?? <ZoneData>[]) {
          for (final mod in zone.modules ?? <Modules>[]) {
            if (mod.id == item.moduleId && mod.pivot?.zoneId == item.zoneId) {
              itemList.add(item);
              idList.add(item.id);
            }
          }
        }
      }
    } else {
      itemList.add(item);
      idList.add(item.id);
    }
  }

  void _addStoreWithModuleFilter(
    dynamic storeJson,
    List<Store?> storeList,
    List<int?> idList,
  ) {
    final module = Get.find<SplashController>().module;
    Store? s;
    try {
      s = Store.fromJson(storeJson);
    } catch (e) {
      debugPrint('FavouriteBloc: error parsing store: $e');
      return;
    }
   

    if (module == null) {
      final address = AddressHelper.getUserAddressFromSharedPref();
      if (address != null) {
        for (final zone in address.zoneData ?? <ZoneData>[]) {
          for (final mod in zone.modules ?? <Modules>[]) {
            if (mod.id == s.moduleId && mod.pivot?.zoneId == s.zoneId) {
              storeList.add(s);
              idList.add(s.id);
            }
          }
        }
      }
    } else if (module.id == s.moduleId) {
      storeList.add(s);
      idList.add(s.id);
    }
  }
}
