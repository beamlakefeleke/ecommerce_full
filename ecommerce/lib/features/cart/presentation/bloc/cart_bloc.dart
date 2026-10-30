import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/cart/data/models/cart_model.dart';
import 'package:ecommerce/features/cart/data/models/online_cart_model.dart';
import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecommerce/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/remove_cart_item_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/update_cart_quantity_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/update_cart_usecase.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/helper/date_converter.dart';
import 'package:ecommerce/helper/module_helper.dart';
import 'package:ecommerce/helper/price_converter.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final AddToCartUseCase addToCartUseCase;
  final UpdateCartUseCase updateCartUseCase;
  final UpdateCartQuantityUseCase updateCartQuantityUseCase;
  final GetCartUseCase getCartUseCase;
  final RemoveCartItemUseCase removeCartItemUseCase;
  final ClearCartUseCase clearCartUseCase;
  final CartRepository repository;

  CartBloc({
    required this.addToCartUseCase,
    required this.updateCartUseCase,
    required this.updateCartQuantityUseCase,
    required this.getCartUseCase,
    required this.removeCartItemUseCase,
    required this.clearCartUseCase,
    required this.repository,
  }) : super(const CartState()) {
    on<CartDataOnlineRequested>(_onGetData);
    on<CartItemAdded>(_onItemAdded);
    on<CartItemQuantityUpdated>(_onQuantityUpdated);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartCleared>(_onCleared);
    on<CartOnlineSynced>(_onOnlineSynced);
    on<CartOnlineUpdated>(_onOnlineUpdated);
    on<CartCutleryToggled>(_onCutleryToggled);
    on<CartNotAvailableIndexSet>(_onNotAvailableIndexSet);
    on<CartCurrentIndexChanged>(_onCurrentIndexChanged);
  }

  // ── handlers ─────────────────────────────────────────────────────────────

  Future<void> _onGetData(
    CartDataOnlineRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(status: CartStatus.loading));
    final result = await getCartUseCase(const NoParams());
    result.fold(
      (f) => emit(
        state.copyWith(status: CartStatus.error, errorMessage: f.message),
      ),
      (online) {
        final cartList = _onlineToLocal(online);
        emit(_recalculate(state.copyWith(cartList: cartList)));
      },
    );
  }

  Future<void> _onItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    final List<CartModel> updated = List.from(state.cartList);
    if (event.index != null && event.index != -1) {
      updated.replaceRange(event.index!, event.index! + 1, [event.cartModel]);
    } else {
      updated.add(event.cartModel);
    }
    await repository.saveCartList(updated);
    emit(_recalculate(state.copyWith(cartList: updated)));
  }

  Future<void> _onQuantityUpdated(
    CartItemQuantityUpdated event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final List<CartModel> updated = List.from(state.cartList);
    final CartModel entry = updated[event.cartIndex];

    // decide new quantity (mirrors CartService.decideItemQuantity)
    int qty = entry.quantity!;
    final bool moduleStock = ModuleHelper.getModuleConfig(
      entry.item!.moduleType,
    ).newVariation!;
    if (event.isIncrement) {
      if (moduleStock && qty >= event.stock!) {
        showCustomSnackBar('out_of_stock'.tr);
      } else if (event.quantityLimit != null &&
          event.quantityLimit != 0 &&
          qty >= event.quantityLimit!) {
        showCustomSnackBar(
          '${'maximum_quantity_limit'.tr} ${event.quantityLimit}',
        );
      } else {
        qty++;
      }
    } else {
      qty--;
    }
    entry.quantity = qty;

    final double discountedPrice = _calculateDiscountedPrice(
      entry,
      qty,
      ModuleHelper.getModuleConfig(entry.item!.moduleType).newVariation!,
    );

    await updateCartQuantityUseCase(
      UpdateCartQuantityParams(
        cartId: entry.id!,
        price: discountedPrice,
        quantity: qty,
      ),
    );

    emit(_recalculate(state.copyWith(cartList: updated, isLoading: false)));
  }

  Future<void> _onItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    final List<CartModel> updated = List.from(state.cartList);
    final int cartId = updated[event.index].id!;
    updated.removeAt(event.index);
    emit(_recalculate(state.copyWith(cartList: updated)));
    await removeCartItemUseCase(cartId);
  }

  Future<void> _onCleared(CartCleared event, Emitter<CartState> emit) async {
    emit(state.copyWith(cartList: const [], subTotal: 0));
    await clearCartUseCase(const NoParams());
  }

  Future<void> _onOnlineSynced(
    CartOnlineSynced event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await addToCartUseCase(AddToCartParams(event.cart));
    result.fold(
      (f) => emit(state.copyWith(isLoading: false, errorMessage: f.message)),
      (online) {
        final cartList = _onlineToLocal(online);
        emit(
          _recalculate(state.copyWith(cartList: cartList, isLoading: false)),
        );
      },
    );
  }

  Future<void> _onOnlineUpdated(
    CartOnlineUpdated event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await updateCartUseCase(UpdateCartParams(event.cart));
    result.fold(
      (f) => emit(state.copyWith(isLoading: false, errorMessage: f.message)),
      (online) {
        final cartList = _onlineToLocal(online);
        emit(
          _recalculate(state.copyWith(cartList: cartList, isLoading: false)),
        );
      },
    );
  }

  void _onCutleryToggled(CartCutleryToggled event, Emitter<CartState> emit) {
    emit(state.copyWith(addCutlery: !state.addCutlery));
  }

  void _onNotAvailableIndexSet(
    CartNotAvailableIndexSet event,
    Emitter<CartState> emit,
  ) {
    final idx = state.notAvailableIndex == event.index ? -1 : event.index;
    emit(state.copyWith(notAvailableIndex: idx));
  }

  void _onCurrentIndexChanged(
    CartCurrentIndexChanged event,
    Emitter<CartState> emit,
  ) {
    emit(state.copyWith(currentIndex: event.index));
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  /// Port of CartService.formatOnlineCartToLocalCart.
  List<CartModel> _onlineToLocal(List<OnlineCartModel> online) {
    final List<CartModel> cartList = [];
    for (final OnlineCartModel cart in online) {
      final double price = cart.item!.price!;
      final double? discount = cart.item!.storeDiscount == 0
          ? cart.item!.discount!
          : cart.item!.storeDiscount!;
      final String? discountType = cart.item!.storeDiscount == 0
          ? cart.item!.discountType
          : 'percent';
      double discountedPrice = PriceConverter.convertWithDiscount(
        price,
        discount,
        discountType,
      )!;
      final double discountAmount = price - discountedPrice;

      final List<List<bool?>> selectedFoodVariations = [];
      if (cart.item!.moduleType == 'food') {
        for (int i = 0; i < cart.item!.foodVariations!.length; i++) {
          selectedFoodVariations.add([]);
          for (
            int j = 0;
            j < cart.item!.foodVariations![i].variationValues!.length;
            j++
          ) {
            selectedFoodVariations[i].add(
              cart.item!.foodVariations![i].variationValues![j].isSelected ??
                  false,
            );
          }
        }
      } else {
        final String variationType =
            cart.productVariation != null && cart.productVariation!.isNotEmpty
            ? cart.productVariation![0].type!
            : '';
        for (final variation in cart.item!.variations!) {
          if (variation.type == variationType) {
            discountedPrice =
                (PriceConverter.convertWithDiscount(
                  variation.price!,
                  discount,
                  discountType,
                )! *
                cart.quantity!);
            break;
          }
        }
      }

      final List<AddOn> addOnIdList = [];
      final List<AddOns> addOnsList = [];
      for (int i = 0; i < cart.addOnIds!.length; i++) {
        addOnIdList.add(
          AddOn(id: cart.addOnIds![i], quantity: cart.addOnQtys![i]),
        );
        for (final addOn in cart.item!.addOns!) {
          if (cart.addOnIds![i] == addOn.id) {
            addOnsList.add(
              AddOns(id: addOn.id, name: addOn.name, price: addOn.price),
            );
          }
        }
      }

      cartList.add(
        CartModel(
          cart.id,
          price,
          discountedPrice,
          cart.productVariation ?? [],
          selectedFoodVariations,
          discountAmount,
          cart.quantity,
          addOnIdList,
          addOnsList,
          false,
          cart.item!.stock ?? 0,
          cart.item,
          cart.item!.quantityLimit,
        ),
      );
    }
    return cartList;
  }

  /// Port of CartController.calculationCart.
  CartState _recalculate(CartState s) {
    double itemPrice = 0;
    double itemDiscountPrice = 0;
    double addOns = 0;
    double variationPrice = 0;
    double variationWithoutDiscountPrice = 0;
    bool isFoodVariation = false;
    bool haveVariation = false;
    final List<List<AddOns>> addOnsList = [];
    final List<bool> availableList = [];

    for (final CartModel m in s.cartList) {
      isFoodVariation = ModuleHelper.getModuleConfig(
        m.item!.moduleType,
      ).newVariation!;
      final double? discount = m.item!.storeDiscount == 0
          ? m.item!.discount
          : m.item!.storeDiscount;
      final String? discountType = m.item!.storeDiscount == 0
          ? m.item!.discountType
          : 'percent';

      final List<AddOns> addOnList = _prepareAddonList(m);
      addOnsList.add(addOnList);
      availableList.add(
        DateConverter.isAvailable(
          m.item!.availableTimeStarts,
          m.item!.availableTimeEnds,
        ),
      );

      for (int i = 0; i < addOnList.length; i++) {
        addOns += addOnList[i].price! * m.addOnIds![i].quantity!;
      }

      if (isFoodVariation) {
        for (int idx = 0; idx < m.item!.foodVariations!.length; idx++) {
          for (
            int i = 0;
            i < m.item!.foodVariations![idx].variationValues!.length;
            i++
          ) {
            if (m.foodVariations![idx][i]!) {
              variationPrice +=
                  (PriceConverter.convertWithDiscount(
                    m
                        .item!
                        .foodVariations![idx]
                        .variationValues![i]
                        .optionPrice!,
                    discount,
                    discountType,
                    isFoodVariation: true,
                  )! *
                  m.quantity!);
              variationWithoutDiscountPrice +=
                  (m
                      .item!
                      .foodVariations![idx]
                      .variationValues![i]
                      .optionPrice! *
                  m.quantity!);
            }
          }
        }
      } else {
        String variationType = '';
        for (int i = 0; i < m.variation!.length; i++) {
          variationType = m.variation![i].type!;
        }
        for (final v in m.item!.variations!) {
          if (v.type == variationType) {
            variationPrice =
                PriceConverter.convertWithDiscount(
                  v.price!,
                  discount,
                  discountType,
                )! *
                m.quantity!;
            haveVariation = true;
            break;
          }
        }
      }

      final double price = haveVariation
          ? variationWithoutDiscountPrice
          : (m.item!.price! * m.quantity!);
      final double discountPrice = haveVariation
          ? (variationWithoutDiscountPrice - variationPrice)
          : price -
                (PriceConverter.convertWithDiscount(
                      m.item!.price!,
                      discount,
                      discountType,
                    )! *
                    m.quantity!);
      itemPrice += price;
      itemDiscountPrice += discountPrice;
      haveVariation = false;
    }

    double subTotal;
    if (isFoodVariation) {
      itemDiscountPrice += (variationWithoutDiscountPrice - variationPrice);
      variationPrice = variationWithoutDiscountPrice;
      subTotal = (itemPrice - itemDiscountPrice) + addOns + variationPrice;
    } else {
      subTotal = itemPrice - itemDiscountPrice;
    }

    return s.copyWith(
      status: CartStatus.loaded,
      subTotal: subTotal,
      itemPrice: itemPrice,
      itemDiscountPrice: itemDiscountPrice,
      addOns: addOns,
      variationPrice: variationPrice,
      addOnsList: addOnsList,
      availableList: availableList,
    );
  }

  List<AddOns> _prepareAddonList(CartModel m) {
    final List<AddOns> addOnList = [];
    for (final addOnId in m.addOnIds!) {
      for (final addOn in m.item!.addOns!) {
        if (addOn.id == addOnId.id) {
          addOnList.add(addOn);
          break;
        }
      }
    }
    return addOnList;
  }

  double _calculateDiscountedPrice(
    CartModel m,
    int quantity,
    bool isFoodVariation,
  ) {
    final double? discount = m.item!.storeDiscount == 0
        ? m.item!.discount
        : m.item!.storeDiscount;
    final String? discountType = m.item!.storeDiscount == 0
        ? m.item!.discountType
        : 'percent';
    double variationPrice = 0;
    double addonPrice = 0;

    if (isFoodVariation) {
      for (int idx = 0; idx < m.item!.foodVariations!.length; idx++) {
        for (
          int i = 0;
          i < m.item!.foodVariations![idx].variationValues!.length;
          i++
        ) {
          if (m.foodVariations![idx][i]!) {
            variationPrice +=
                (PriceConverter.convertWithDiscount(
                  m.item!.foodVariations![idx].variationValues![i].optionPrice!,
                  discount,
                  discountType,
                  isFoodVariation: true,
                )! *
                m.quantity!);
          }
        }
      }
      final List<AddOns> addOnList = _prepareAddonList(m);
      for (int i = 0; i < addOnList.length; i++) {
        addonPrice += addOnList[i].price! * m.addOnIds![i].quantity!;
      }
    }

    return addonPrice +
        variationPrice +
        (m.item!.price! * quantity) -
        PriceConverter.calculation(
          m.item!.price!,
          discount,
          discountType!,
          quantity,
        );
  }
}
