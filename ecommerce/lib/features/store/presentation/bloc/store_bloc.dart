import 'package:ecommerce/helper/module_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/category/data/models/category_model.dart';
import 'package:ecommerce/features/category/presentation/bloc/category_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_event.dart';

import 'package:ecommerce/features/language/presentation/bloc/language_bloc.dart';
import 'package:ecommerce/features/location/presentation/helper/location_helper.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/features/store/domain/usecases/store_usecases.dart';
import 'package:ecommerce/features/store/presentation/bloc/store_event.dart';
import 'package:ecommerce/features/store/presentation/bloc/store_state.dart';
import 'package:ecommerce/helper/address_helper.dart';
import 'package:ecommerce/helper/date_converter.dart';

export 'store_event.dart';
export 'store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final GetStoreListUseCase getStoreList;
  final GetPopularStoreListUseCase getPopularStoreList;
  final GetLatestStoreListUseCase getLatestStoreList;
  final GetFeaturedStoreListUseCase getFeaturedStoreList;
  final GetVisitAgainStoreListUseCase getVisitAgainStoreList;
  final GetRecommendedStoreListUseCase getRecommendedStoreList;
  final GetStoreDetailsUseCase getStoreDetails;
  final GetStoreItemListUseCase getStoreItemList;
  final GetStoreSearchItemListUseCase getStoreSearchItemList;
  final GetStoreRecommendedItemListUseCase getStoreRecommendedItemList;
  final GetCartStoreSuggestedItemListUseCase getCartStoreSuggestedItemList;
  final GetStoreBannerListUseCase getStoreBannerList;

  StoreBloc({
    required this.getStoreList,
    required this.getPopularStoreList,
    required this.getLatestStoreList,
    required this.getFeaturedStoreList,
    required this.getVisitAgainStoreList,
    required this.getRecommendedStoreList,
    required this.getStoreDetails,
    required this.getStoreItemList,
    required this.getStoreSearchItemList,
    required this.getStoreRecommendedItemList,
    required this.getCartStoreSuggestedItemList,
    required this.getStoreBannerList,
  }) : super(const StoreState()) {
    on<StoreListRequested>(_onStoreListRequested);
    on<PopularStoreListRequested>(_onPopularStoreListRequested);
    on<LatestStoreListRequested>(_onLatestStoreListRequested);
    on<FeaturedStoreListRequested>(_onFeaturedStoreListRequested);
    on<VisitAgainStoreListRequested>(_onVisitAgainStoreListRequested);
    on<RecommendedStoreListRequested>(_onRecommendedStoreListRequested);
    on<StoreDetailsRequested>(_onStoreDetailsRequested);
    on<StoreItemListRequested>(_onStoreItemListRequested);
    on<StoreSearchItemListRequested>(_onStoreSearchItemListRequested);
    on<StoreRecommendedItemListRequested>(_onStoreRecommendedItemListRequested);
    on<CartStoreSuggestedItemListRequested>(
      _onCartStoreSuggestedItemListRequested,
    );
    on<StoreBannerListRequested>(_onStoreBannerListRequested);
    on<StoreCategoryIndexChanged>(_onStoreCategoryIndexChanged);
    on<StoreSearchStatusToggled>(_onStoreSearchStatusToggled);
    on<StoreSearchDataInitialized>(_onStoreSearchDataInitialized);
    on<StorePrescriptionImagePicked>(_onStorePrescriptionImagePicked);
    on<StorePrescriptionImageRemoved>(_onStorePrescriptionImageRemoved);
    on<StoreFavVisibilityChanged>(_onStoreFavVisibilityChanged);
    on<StoreAnimationHidden>(_onStoreAnimationHidden);
    on<StoreButtonAnimationShown>(_onStoreButtonAnimationShown);
    on<StoreTypeChanged>(_onStoreTypeChanged);
  }

  // ── handlers ────────────────────────────────────────────────────────────────

  Future<void> _onStoreListRequested(
    StoreListRequested event,
    Emitter<StoreState> emit,
  ) async {
    if (event.offset == 1) {
      emit(state.copyWith(clearStoreModel: true));
    }
    final result = await getStoreList(
      StoreListParams(offset: event.offset, filterBy: event.filterBy),
    );
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (model) {
        if (event.offset == 1) {
          emit(state.copyWith(storeModel: model));
        } else {
          final existing = state.storeModel;
          if (existing != null) {
            existing.totalSize = model.totalSize;
            existing.offset = model.offset;
            existing.stores!.addAll(model.stores ?? []);
            emit(state.copyWith(storeModel: existing));
          }
        }
      },
    );
  }

  Future<void> _onPopularStoreListRequested(
    PopularStoreListRequested event,
    Emitter<StoreState> emit,
  ) async {
    if (event.reload) {
      emit(state.copyWith(popularStoreList: []));
    }
    if (state.popularStoreList == null || event.reload) {
      final result = await getPopularStoreList(TypeParams(event.type));
      result.fold(
        (failure) => emit(state.copyWith(errorMessage: failure.message)),
        (list) =>
            emit(state.copyWith(popularStoreList: list, type: event.type)),
      );
    } else {
      emit(state.copyWith(type: event.type));
    }
  }

  Future<void> _onLatestStoreListRequested(
    LatestStoreListRequested event,
    Emitter<StoreState> emit,
  ) async {
    if (event.reload) {
      emit(state.copyWith(latestStoreList: []));
    }
    if (state.latestStoreList == null || event.reload) {
      final result = await getLatestStoreList(TypeParams(event.type));
      result.fold(
        (failure) => emit(state.copyWith(errorMessage: failure.message)),
        (list) => emit(state.copyWith(latestStoreList: list, type: event.type)),
      );
    } else {
      emit(state.copyWith(type: event.type));
    }
  }

  Future<void> _onFeaturedStoreListRequested(
    FeaturedStoreListRequested event,
    Emitter<StoreState> emit,
  ) async {
    final result = await getFeaturedStoreList(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (list) => emit(state.copyWith(featuredStoreList: list)),
    );
  }

  Future<void> _onVisitAgainStoreListRequested(
    VisitAgainStoreListRequested event,
    Emitter<StoreState> emit,
  ) async {
    if (event.fromModule) {
      emit(state.copyWith(visitAgainStoreList: []));
    }
    final result = await getVisitAgainStoreList(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (list) => emit(state.copyWith(visitAgainStoreList: list)),
    );
  }

  Future<void> _onRecommendedStoreListRequested(
    RecommendedStoreListRequested event,
    Emitter<StoreState> emit,
  ) async {
    emit(state.copyWith(recommendedStoreList: []));
    final result = await getRecommendedStoreList(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (list) => emit(state.copyWith(recommendedStoreList: list)),
    );
  }

  Future<void> _onStoreDetailsRequested(
    StoreDetailsRequested event,
    Emitter<StoreState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, categoryIndex: 0, clearStore: true));

    final languageCode =
        getIt<LanguageBloc>().state.locale.languageCode;
    final splashState = getIt<SplashBloc>().state;

    final result = await getStoreDetails(
      StoreDetailsParams(
        storeID: event.storeID,
        fromCart: event.fromCart,
        slug: event.slug,
        languageCode: languageCode,
        module: ModuleHelper.getModule(),
        cacheModuleId: ModuleHelper.getCacheModule()?.id,
        moduleId: ModuleHelper.getModule()?.id,
      ),
    );

    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (store) {
        // Build category list from CategoryBloc
        final categoryBloc = getIt<CategoryBloc>();
        List<CategoryModel>? categoryList;
        if (categoryBloc.state.categories.isNotEmpty &&
            store.categoryIds != null) {
          categoryList = [CategoryModel(id: 0, name: 'all'.tr)];
          for (final c in categoryBloc.state.categories) {
            final catModel = CategoryModel(
              id: c.id,
              name: c.name,
              image: c.image,
            );
            if (store.categoryIds!.contains(c.id)) {
              categoryList.add(catModel);
            }
          }
        }

        emit(
          state.copyWith(
            store: store,
            isLoading: false,
            categoryList: categoryList,
            clearError: true,
          ),
        );

        // Dispatch cross-feature side effects (checkout initialization)
        final checkoutBloc = getIt<CheckoutBloc>();
        checkoutBloc.add(CheckoutTimeSlotInitialized(store));

        if (!event.fromCart && event.slug.isEmpty) {
          final userAddr = AddressHelper.getUserAddressFromSharedPref();
          if (userAddr?.latitude != null && userAddr?.longitude != null) {
            checkoutBloc.add(
              CheckoutDistanceRequested(
                origin: LatLng(
                  double.parse(userAddr!.latitude!),
                  double.parse(userAddr.longitude!),
                ),
                destination: LatLng(
                  double.parse(store.latitude!),
                  double.parse(store.longitude!),
                ),
              ),
            );
          }
        }

        if (event.slug.isNotEmpty) {
          LocationHelper.setStoreAddressToUserAddress(
            LatLng(
              double.parse(store.latitude!),
              double.parse(store.longitude!),
            ),
          );
        }

        if (!event.fromCart && event.slug.isEmpty) {
          checkoutBloc.add(const CheckoutPrevDataCleared());
        }

        checkoutBloc.add(
          CheckoutOrderTypeChanged(store.delivery! ? 'delivery' : 'take_away'),
        );
      },
    );
  }

  Future<void> _onStoreItemListRequested(
    StoreItemListRequested event,
    Emitter<StoreState> emit,
  ) async {
    if (event.offset == 1 || state.storeItemModel == null) {
      emit(state.copyWith(type: event.type, clearStoreItemModel: true));
    }

    // Use the current category index to filter
    final int? categoryID =
        (state.store != null &&
            state.store!.categoryIds != null &&
            state.store!.categoryIds!.isNotEmpty &&
            state.categoryIndex != 0 &&
            state.categoryList != null &&
            state.categoryIndex < state.categoryList!.length)
        ? state.categoryList![state.categoryIndex].id
        : 0;

    final result = await getStoreItemList(
      StoreItemListParams(
        storeID: event.storeID,
        offset: event.offset,
        categoryID: categoryID,
        type: event.type,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (model) {
        if (event.offset == 1) {
          emit(state.copyWith(storeItemModel: model));
        } else {
          final existing = state.storeItemModel;
          if (existing != null) {
            existing.items!.addAll(model.items ?? []);
            existing.totalSize = model.totalSize;
            existing.offset = model.offset;
            emit(state.copyWith(storeItemModel: existing));
          }
        }
      },
    );
  }

  Future<void> _onStoreSearchItemListRequested(
    StoreSearchItemListRequested event,
    Emitter<StoreState> emit,
  ) async {
    if (event.searchText.isEmpty) {
      // Let the UI show a snackbar — emit a transient error message
      emit(state.copyWith(errorMessage: 'write_item_name'));
      emit(state.copyWith(clearError: true));
      return;
    }

    emit(
      state.copyWith(
        isSearching: true,
        searchText: event.searchText,
        type: event.type,
      ),
    );

    if (event.offset == 1 || state.storeSearchItemModel == null) {
      emit(
        state.copyWith(searchType: event.type, clearStoreSearchItemModel: true),
      );
    }

    final int? categoryID =
        (state.store != null &&
            state.store!.categoryIds != null &&
            state.store!.categoryIds!.isNotEmpty &&
            state.categoryIndex != 0 &&
            state.categoryList != null &&
            state.categoryIndex < state.categoryList!.length)
        ? state.categoryList![state.categoryIndex].id
        : 0;

    final result = await getStoreSearchItemList(
      StoreSearchItemListParams(
        searchText: event.searchText,
        storeID: event.storeID,
        offset: event.offset,
        type: event.type,
        categoryID: categoryID,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (model) {
        if (event.offset == 1) {
          emit(state.copyWith(storeSearchItemModel: model));
        } else {
          final existing = state.storeSearchItemModel;
          if (existing != null) {
            existing.items!.addAll(model.items ?? []);
            existing.totalSize = model.totalSize;
            existing.offset = model.offset;
            emit(state.copyWith(storeSearchItemModel: existing));
          }
        }
      },
    );
  }

  Future<void> _onStoreRecommendedItemListRequested(
    StoreRecommendedItemListRequested event,
    Emitter<StoreState> emit,
  ) async {
    final result = await getStoreRecommendedItemList(
      StoreIdParams(event.storeId),
    );
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (model) => emit(state.copyWith(recommendedItemModel: model)),
    );
  }

  Future<void> _onCartStoreSuggestedItemListRequested(
    CartStoreSuggestedItemListRequested event,
    Emitter<StoreState> emit,
  ) async {
    final languageCode =
        getIt<LanguageBloc>().state.locale.languageCode;

    final result = await getCartStoreSuggestedItemList(
      CartSuggestedParams(
        storeId: event.storeId,
        languageCode: languageCode,
        module: ModuleHelper.getModule(),
        cacheModuleId: ModuleHelper.getCacheModule()?.id,
        moduleId: ModuleHelper.getModule()?.id,
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (model) => emit(state.copyWith(cartSuggestItemModel: model)),
    );
  }

  Future<void> _onStoreBannerListRequested(
    StoreBannerListRequested event,
    Emitter<StoreState> emit,
  ) async {
    final result = await getStoreBannerList(StoreIdParams(event.storeId));
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (banners) => emit(state.copyWith(storeBanners: banners)),
    );
  }

  void _onStoreCategoryIndexChanged(
    StoreCategoryIndexChanged event,
    Emitter<StoreState> emit,
  ) {
    emit(state.copyWith(categoryIndex: event.index));
    if (event.itemSearching) {
      emit(state.copyWith(clearStoreSearchItemModel: true));
      add(
        StoreSearchItemListRequested(
          searchText: state.searchText,
          storeID: state.store?.id.toString(),
          offset: 1,
          type: state.type,
        ),
      );
    } else {
      emit(state.copyWith(clearStoreItemModel: true));
      add(
        StoreItemListRequested(
          storeID: state.store?.id,
          offset: 1,
          type: state.type,
        ),
      );
    }
  }

  void _onStoreSearchStatusToggled(
    StoreSearchStatusToggled event,
    Emitter<StoreState> emit,
  ) {
    emit(state.copyWith(isSearching: !state.isSearching));
  }

  void _onStoreSearchDataInitialized(
    StoreSearchDataInitialized event,
    Emitter<StoreState> emit,
  ) {
    emit(state.copyWith(clearStoreSearchItemModel: true, searchText: ''));
  }

  Future<void> _onStorePrescriptionImagePicked(
    StorePrescriptionImagePicked event,
    Emitter<StoreState> emit,
  ) async {
    if (event.isRemove) {
      emit(state.copyWith(pickedPrescriptions: []));
      return;
    }
    final XFile? xFile = await ImagePicker().pickImage(
      source: event.isCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 50,
    );
    if (xFile != null) {
      emit(
        state.copyWith(
          pickedPrescriptions: [...state.pickedPrescriptions, xFile],
        ),
      );
    }
  }

  void _onStorePrescriptionImageRemoved(
    StorePrescriptionImageRemoved event,
    Emitter<StoreState> emit,
  ) {
    final updated = List<XFile>.from(state.pickedPrescriptions)
      ..removeAt(event.index);
    emit(state.copyWith(pickedPrescriptions: updated));
  }

  void _onStoreFavVisibilityChanged(
    StoreFavVisibilityChanged event,
    Emitter<StoreState> emit,
  ) {
    emit(state.copyWith(showFavButton: !state.showFavButton));
  }

  void _onStoreAnimationHidden(
    StoreAnimationHidden event,
    Emitter<StoreState> emit,
  ) {
    emit(state.copyWith(currentState: false));
  }

  Future<void> _onStoreButtonAnimationShown(
    StoreButtonAnimationShown event,
    Emitter<StoreState> emit,
  ) async {
    await Future.delayed(const Duration(seconds: 3));
    emit(state.copyWith(currentState: true));
  }

  void _onStoreTypeChanged(StoreTypeChanged event, Emitter<StoreState> emit) {
    emit(state.copyWith(storeType: event.storeType));
    add(StoreListRequested(offset: 1, filterBy: event.storeType));
  }

  // ── Pure helpers (ported from StoreController) ───────────────────────────

  static bool isStoreClosed(
    bool today,
    bool active,
    List<Schedules>? schedules,
  ) {
    if (!active) return true;
    DateTime date = DateTime.now();
    if (!today) date = date.add(const Duration(days: 1));
    int weekday = date.weekday;
    if (weekday == 7) weekday = 0;
    for (int i = 0; i < (schedules?.length ?? 0); i++) {
      if (weekday == schedules![i].day) return false;
    }
    return true;
  }

  static bool isStoreOpenNow(bool active, List<Schedules>? schedules) {
    if (isStoreClosed(true, active, schedules)) return false;
    int weekday = DateTime.now().weekday;
    if (weekday == 7) weekday = 0;
    for (int i = 0; i < (schedules?.length ?? 0); i++) {
      if (weekday == schedules![i].day &&
          DateConverter.isAvailable(
            schedules[i].openingTime,
            schedules[i].closingTime,
          )) {
        return true;
      }
    }
    return false;
  }

  static bool isOpenNow(Store store) =>
      store.open == 1 && (store.active ?? false);

  static double getDiscount(Store store) => store.discount?.discount ?? 0;

  static String getDiscountType(Store store) =>
      store.discount?.discountType ?? 'percent';
}
