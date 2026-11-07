import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/cart/data/models/cart_model.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/item/domain/models/basic_medicine_model.dart';
import 'package:ecommerce/features/item/domain/models/common_condition_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/item/domain/usecases/item_usecases.dart';
import 'package:ecommerce/features/item/presentation/helpers/item_helper.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/helper/module_helper.dart';
import 'package:get/get.dart';

part 'item_event.dart';
part 'item_state.dart';

class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final GetPopularItemsUseCase getPopularItems;
  final GetReviewedItemsUseCase getReviewedItems;
  final GetFeaturedCategoriesItemsUseCase getFeaturedCategoriesItems;
  final GetRecommendedItemsUseCase getRecommendedItems;
  final GetDiscountedItemsUseCase getDiscountedItems;
  final GetItemDetailsUseCase getItemDetails;
  final GetBasicMedicineUseCase getBasicMedicine;
  final GetCommonConditionsUseCase getCommonConditions;
  final GetConditionsWiseItemsUseCase getConditionsWiseItems;

  ItemBloc({
    required this.getPopularItems,
    required this.getReviewedItems,
    required this.getFeaturedCategoriesItems,
    required this.getRecommendedItems,
    required this.getDiscountedItems,
    required this.getItemDetails,
    required this.getBasicMedicine,
    required this.getCommonConditions,
    required this.getConditionsWiseItems,
  }) : super(const ItemState()) {
    on<PopularItemsRequested>(_onPopular);
    on<ReviewedItemsRequested>(_onReviewed);
    on<DiscountedItemsRequested>(_onDiscounted);
    on<RecommendedItemsRequested>(_onRecommended);
    on<FeaturedCategoriesItemsRequested>(_onFeatured);
    on<BasicMedicineRequested>(_onBasicMedicine);
    on<CommonConditionsRequested>(_onCommonConditions);
    on<ConditionsWiseItemsRequested>(_onConditionsWise);
    on<CommonConditionSelected>(_onCommonConditionSelected);
    on<FeaturedCategorySelected>(_onFeaturedCategorySelected);
    on<ItemCurrentIndexChanged>(
      (e, emit) => emit(state.copyWith(currentIndex: e.index)),
    );
    on<ProductDetailsRequested>(_onProductDetails);
    on<ItemDataInitialized>((e, emit) => _initData(emit, e.item, e.cart));
    on<AddOnQuantityChanged>(_onAddOnQuantity);
    on<ItemQuantityChanged>(_onQuantity);
    on<CartVariationIndexSet>(_onCartVariationIndex);
    on<NewCartVariationIndexSet>(_onNewCartVariationIndex);
    on<AddOnToggled>(_onAddOnToggled);
    on<VariationSectionToggled>(_onVariationSectionToggled);
    on<ItemImageIndexChanged>(
      (e, emit) => emit(state.copyWith(imageIndex: e.index)),
    );
    on<ProductSelectChanged>(
      (e, emit) => emit(state.copyWith(productSelect: e.select)),
    );
    on<ImageSliderIndexChanged>(
      (e, emit) => emit(state.copyWith(imageSliderIndex: e.index)),
    );
    on<ReadMoreToggled>(
      (e, emit) => emit(state.copyWith(isReadMore: !state.isReadMore)),
    );
    on<ExistInCartChecked>((e, emit) => _setExistInCart(emit, e.item));
  }

  // ── List loaders ───────────────────────────────────────────────────────────

  Future<void> _onPopular(
    PopularItemsRequested event,
    Emitter<ItemState> emit,
  ) async {
    emit(state.copyWith(popularType: event.type));
    if (state.popularItemList != null && !event.reload) return;
    emit(state.copyWith(clearPopular: true));
    final result = await getPopularItems(TypeParams(event.type));
    result.fold(
      (f) {},
      (items) => emit(state.copyWith(popularItemList: items, isLoading: false)),
    );
  }

  Future<void> _onReviewed(
    ReviewedItemsRequested event,
    Emitter<ItemState> emit,
  ) async {
    emit(state.copyWith(reviewedType: event.type));
    if (state.reviewedItemList != null && !event.reload) return;
    emit(state.copyWith(clearReviewed: true));
    final result = await getReviewedItems(TypeParams(event.type));
    result.fold(
      (f) {},
      (model) => emit(
        state.copyWith(
          reviewedItemList: model.items,
          reviewedCategoriesList: model.categories,
          isLoading: false,
        ),
      ),
    );
  }

  Future<void> _onDiscounted(
    DiscountedItemsRequested event,
    Emitter<ItemState> emit,
  ) async {
    emit(state.copyWith(discountedType: event.type));
    if (state.discountedItemList != null && !event.reload) return;
    emit(state.copyWith(clearDiscounted: true));
    final result = await getDiscountedItems(TypeParams(event.type));
    result.fold(
      (f) {},
      (items) =>
          emit(state.copyWith(discountedItemList: items, isLoading: false)),
    );
  }

  Future<void> _onRecommended(
    RecommendedItemsRequested event,
    Emitter<ItemState> emit,
  ) async {
    if (state.recommendedItemList != null && !event.reload) return;
    emit(state.copyWith(clearRecommended: true));
    final result = await getRecommendedItems(TypeParams(event.type));
    result.fold(
      (f) {},
      (items) =>
          emit(state.copyWith(recommendedItemList: items, isLoading: false)),
    );
  }

  Future<void> _onFeatured(
    FeaturedCategoriesItemsRequested event,
    Emitter<ItemState> emit,
  ) async {
    if (state.featuredCategoriesItem != null && !event.reload) return;
    emit(state.copyWith(clearFeatured: true));
    final result = await getFeaturedCategoriesItems(const NoParams());
    result.fold(
      (f) {},
      (model) => emit(state.copyWith(featuredCategoriesItem: model)),
    );
  }

  Future<void> _onBasicMedicine(
    BasicMedicineRequested event,
    Emitter<ItemState> emit,
  ) async {
    if (state.basicMedicineModel != null && !event.reload) return;
    emit(state.copyWith(clearMedicine: true));
    final result = await getBasicMedicine(const NoParams());
    result.fold(
      (f) {},
      (model) =>
          emit(state.copyWith(basicMedicineModel: model, isLoading: false)),
    );
  }

  Future<void> _onCommonConditions(
    CommonConditionsRequested event,
    Emitter<ItemState> emit,
  ) async {
    final result = await getCommonConditions(const NoParams());
    result.fold(
      (f) {},
      (list) => emit(state.copyWith(commonConditions: list, isLoading: false)),
    );
  }

  Future<void> _onConditionsWise(
    ConditionsWiseItemsRequested event,
    Emitter<ItemState> emit,
  ) async {
    emit(state.copyWith(clearConditionWise: true));
    final result = await getConditionsWiseItems(ConditionIdParams(event.id));
    result.fold(
      (f) {},
      (items) =>
          emit(state.copyWith(conditionWiseProduct: items, isLoading: false)),
    );
  }

  Future<void> _onCommonConditionSelected(
    CommonConditionSelected event,
    Emitter<ItemState> emit,
  ) async {
    emit(state.copyWith(selectedCommonCondition: event.index));
    add(ConditionsWiseItemsRequested(state.commonConditions![event.index].id!));
  }

  void _onFeaturedCategorySelected(
    FeaturedCategorySelected event,
    Emitter<ItemState> emit,
  ) {
    emit(state.copyWith(selectedCategory: event.index));
  }

  // ── Item details / selection state ───────────────────────────────────────

  Future<void> _onProductDetails(
    ProductDetailsRequested event,
    Emitter<ItemState> emit,
  ) async {
    Item? item;
    if (event.item.name != null) {
      item = event.item;
    } else {
      final result = await getItemDetails(GetItemDetailsParams(event.item.id));
      result.fold((f) => item = null, (i) => item = i);
    }
    emit(state.copyWith(item: item, clearItem: item == null));
    if (item != null) {
      _initData(emit, item, null);
      _setExistInCart(emit, item);
    }
  }

  void _initData(Emitter<ItemState> emit, Item? item, CartModel? cart) {
    List<int> variationIndex = [];
    List<int?> addOnQtyList = [];
    List<bool> addOnActiveList = [];
    List<List<bool?>> selectedVariations = [];
    List<bool> collapseVariation = [];
    int quantity = 1;

    if (cart != null) {
      quantity = cart.quantity ?? 1;
      addOnActiveList = ItemHelper.initializeCartAddonActiveList(
        cart.addOnIds,
        item!.addOns,
      );
      addOnQtyList = ItemHelper.initializeCartAddonsQtyList(
        cart.addOnIds,
        item.addOns,
      );
      if (ModuleHelper.getModuleConfig(item.moduleType).newVariation!) {
        selectedVariations = List.of(cart.foodVariations!);
        collapseVariation = ItemHelper.collapseVariation(item.foodVariations!);
      } else {
        variationIndex = ItemHelper.initializeCartVariationIndexes(
          cart.variation,
          item.choiceOptions,
        );
      }
      emit(
        state.copyWith(
          variationIndex: variationIndex,
          addOnQtyList: addOnQtyList,
          addOnActiveList: addOnActiveList,
          selectedVariations: selectedVariations,
          collapseVariation: collapseVariation,
          quantity: quantity,
        ),
      );
    } else {
      if (ModuleHelper.getModuleConfig(item!.moduleType).newVariation!) {
        selectedVariations = ItemHelper.initializeSelectedVariation(
          item.foodVariations,
        );
        collapseVariation = ItemHelper.initializeCollapseVariation(
          item.foodVariations,
        );
      } else {
        variationIndex = ItemHelper.initializeVariationIndexes(
          item.choiceOptions,
        );
      }
      addOnActiveList = ItemHelper.initializeAddonActiveList(item.addOns);
      addOnQtyList = ItemHelper.initializeAddonQtyList(item.addOns);
      emit(
        state.copyWith(
          variationIndex: variationIndex,
          addOnQtyList: addOnQtyList,
          addOnActiveList: addOnActiveList,
          selectedVariations: selectedVariations,
          collapseVariation: collapseVariation,
          quantity: 1,
        ),
      );
      _setExistInCart(emit, item);
    }
  }

  void _setExistInCart(Emitter<ItemState> emit, Item? item) {
    final String variationType = ItemHelper.prepareVariationType(
      item!.choiceOptions,
      state.variationIndex,
    );

    int cartIndex;
    if (ModuleHelper.getModuleConfig(
      ModuleHelper.getModule() != null
          ? ModuleHelper.getModule()!.moduleType
          : ModuleHelper.getCacheModule()!.moduleType,
    ).newVariation!) {
      cartIndex = -1;
    } else {
      cartIndex = _isExistInCart(item.id, variationType);
    }

    if (cartIndex != -1) {
      final cartList = getIt<CartBloc>().state.cartList;
      emit(
        state.copyWith(
          cartIndex: cartIndex,
          quantity: cartList[cartIndex].quantity,
          addOnActiveList: ItemHelper.initializeCartAddonActiveList(
            cartList[cartIndex].addOnIds,
            item.addOns,
          ),
          addOnQtyList: ItemHelper.initializeCartAddonsQtyList(
            cartList[cartIndex].addOnIds,
            item.addOns,
          ),
        ),
      );
    } else {
      emit(state.copyWith(cartIndex: cartIndex));
    }
  }

  /// Port of the legacy `CartController.isExistInCart` (non-food variation).
  int _isExistInCart(int? itemId, String variationType) {
    final cartList = getIt<CartBloc>().state.cartList;
    for (int index = 0; index < cartList.length; index++) {
      final cart = cartList[index];
      if (cart.item!.id == itemId &&
          (cart.variation!.isEmpty ? '' : cart.variation![0].type) ==
              variationType) {
        return index;
      }
    }
    return -1;
  }

  void _onAddOnQuantity(AddOnQuantityChanged event, Emitter<ItemState> emit) {
    final list = List<int?>.of(state.addOnQtyList);
    list[event.index] = ItemHelper.setAddOnQuantity(
      event.isIncrement,
      list[event.index]!,
    );
    emit(state.copyWith(addOnQtyList: list));
  }

  void _onQuantity(ItemQuantityChanged event, Emitter<ItemState> emit) {
    final int newQty = ItemHelper.setQuantity(
      event.isIncrement,
      Get.find<SplashController>().configModel!.moduleConfig!.module!.stock!,
      event.stock,
      state.quantity!,
      event.quantityLimit,
      getxSnackBar: event.getxSnackBar,
    );
    emit(state.copyWith(quantity: newQty));
  }

  void _onCartVariationIndex(
    CartVariationIndexSet event,
    Emitter<ItemState> emit,
  ) {
    final list = List<int>.of(state.variationIndex ?? []);
    list[event.index] = event.i;
    emit(state.copyWith(variationIndex: list, quantity: 1));
    _setExistInCart(emit, event.item);
  }

  void _onNewCartVariationIndex(
    NewCartVariationIndexSet event,
    Emitter<ItemState> emit,
  ) {
    final updated = ItemHelper.setNewCartVariationIndex(
      event.index,
      event.i,
      event.item.foodVariations!,
      List<List<bool?>>.of(
        state.selectedVariations.map((e) => List<bool?>.of(e)),
      ),
    );
    emit(state.copyWith(selectedVariations: updated));
  }

  void _onAddOnToggled(AddOnToggled event, Emitter<ItemState> emit) {
    final list = List<bool>.of(state.addOnActiveList);
    list[event.index] = event.isAdd;
    emit(state.copyWith(addOnActiveList: list));
  }

  void _onVariationSectionToggled(
    VariationSectionToggled event,
    Emitter<ItemState> emit,
  ) {
    final list = List<bool>.of(state.collapseVariation);
    list[event.index] = !list[event.index];
    emit(state.copyWith(collapseVariation: list));
  }
}
