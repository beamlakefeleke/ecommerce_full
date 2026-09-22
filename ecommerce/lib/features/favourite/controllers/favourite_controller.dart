import 'package:get/get.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/favourite/domain/services/favourite_service_interface.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_bloc.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_event.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_state.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';

/// Thin GetX adapter — delegates to [FavouriteBloc].
class FavouriteController extends GetxController implements GetxService {
  // ignore: unused_field
  final FavouriteServiceInterface favouriteServiceInterface;
  FavouriteController({required this.favouriteServiceInterface});

  FavouriteBloc get _bloc => getIt<FavouriteBloc>();
  FavouriteState get _state => _bloc.state;

  // ─── Getters ─────────────────────────────────────────────────────────────
  List<Item?> get wishItemList => _state.wishItemList;
  List<Store?> get wishStoreList => _state.wishStoreList;
  List<int?> get wishItemIdList => _state.wishItemIdList;
  List<int?> get wishStoreIdList => _state.wishStoreIdList;
  bool get isRemoving => _state.isRemoving;

  // ─── Methods ─────────────────────────────────────────────────────────────

  void addToFavouriteList(
    Item? product,
    Store? store,
    bool isStore, {
    bool getXSnackBar = false,
  }) {
    _bloc.add(FavouriteAdded(item: product, store: store, isStore: isStore));
    update();
  }

  void removeFromFavouriteList(
    int? id,
    bool isStore, {
    bool getXSnackBar = false,
  }) {
    _bloc.add(FavouriteRemoved(id: id, isStore: isStore));
    update();
  }

  Future<void> getFavouriteList() async {
    _bloc.add(const FavouriteListFetched());
    await Future.delayed(Duration.zero);
    update();
  }

  void removeFavourite() {
    _bloc.add(const FavouriteLocalCleared());
    update();
  }
}
