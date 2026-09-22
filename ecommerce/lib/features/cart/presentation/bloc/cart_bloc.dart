import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';
import 'package:ecommerce/features/cart/domain/usecases/get_shared_pref_cart_list_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/add_shared_pref_cart_list_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/add_to_cart_online_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/delete_cart_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/get_cart_data_online_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/update_cart_online_usecase.dart';
import 'package:ecommerce/features/cart/domain/usecases/update_cart_quantity_online_usecase.dart';
import 'package:ecommerce/features/cart/domain/services/cart_service_interface.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/module_helper.dart';
import 'package:ecommerce/helper/date_converter.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/features/cart/domain/entities/cart.dart';
import 'package:ecommerce/features/cart/domain/entities/online_cart.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetSharedPrefCartListUseCase getSharedPrefCartListUseCase;
  final AddSharedPrefCartListUseCase addSharedPrefCartListUseCase;
  final AddToCartOnlineUseCase addToCartOnlineUseCase;
  final DeleteCartUseCase deleteCartUseCase;
  final GetCartDataOnlineUseCase getCartDataOnlineUseCase;
  final UpdateCartOnlineUseCase updateCartOnlineUseCase;
  final UpdateCartQuantityOnlineUseCase updateCartQuantityOnlineUseCase;
  final CartServiceInterface cartServiceInterface;

  CartBloc({
    required this.getSharedPrefCartListUseCase,
    required this.addSharedPrefCartListUseCase,
    required this.addToCartOnlineUseCase,
    required this.deleteCartUseCase,
    required this.getCartDataOnlineUseCase,
    required this.updateCartOnlineUseCase,
    required this.updateCartQuantityOnlineUseCase,
    required this.cartServiceInterface,
  }) : super(const CartState()) {
    on<GetCartDataEvent>(_onGetCartData);
    on<SetAvailableIndexEvent>(_onSetAvailableIndex);
    on<UpdateCutleryEvent>(_onUpdateCutlery);
    on<CalculationCartEvent>(_onCalculationCart);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<SetQuantityEvent>(_onSetQuantity);
    on<ClearCartEvent>(_onClearCart);
  }

  void _onGetCartData(GetCartDataEvent event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.loading));

    if ((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) &&
        (ModuleHelper.getModule() != null ||
            ModuleHelper.getCacheModule() != null)) {
      final result = await getCartDataOnlineUseCase();
      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: CartStatus.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (onlineCartList) {
          final cartList = cartServiceInterface.formatOnlineCartToLocalCart(
            onlineCartModel: onlineCartList,
          );
          emit(state.copyWith(cartList: cartList));
          addSharedPrefCartListUseCase(cartList);
          add(CalculationCartEvent());
        },
      );
    } else {
      final cartList = getSharedPrefCartListUseCase();
      emit(state.copyWith(cartList: cartList));
      add(CalculationCartEvent());
    }
  }

  void _onSetAvailableIndex(
    SetAvailableIndexEvent event,
    Emitter<CartState> emit,
  ) {
    int index = event.index;
    if (state.notAvailableIndex == index) {
      index = -1;
    }
    emit(state.copyWith(notAvailableIndex: index));
  }

  void _onUpdateCutlery(UpdateCutleryEvent event, Emitter<CartState> emit) {
    emit(state.copyWith(addCutlery: !state.addCutlery));
  }

  void _onCalculationCart(CalculationCartEvent event, Emitter<CartState> emit) {
    List<List<AddOns>> addOnsList = [];
    List<bool> availableList = [];
    double itemPrice = 0;
    double itemDiscountPrice = 0;
    double addOns = 0;
    double variationPrice = 0;
    bool isFoodVariation = false;
    double variationWithoutDiscountPrice = 0;
    bool haveVariation = false;

    for (var cartModel in state.cartList) {
      isFoodVariation =
          ModuleHelper.getModuleConfig(
            cartModel.item?.moduleType,
          ).newVariation ??
          false;
      double? discount = cartModel.item!.storeDiscount == 0
          ? cartModel.item!.discount
          : cartModel.item!.storeDiscount;
      String? discountType = cartModel.item!.storeDiscount == 0
          ? cartModel.item!.discountType
          : 'percent';

      List<AddOns> addOnList = cartServiceInterface.prepareAddonList(cartModel);

      addOnsList.add(addOnList);
      availableList.add(
        DateConverter.isAvailable(
          cartModel.item!.availableTimeStarts,
          cartModel.item!.availableTimeEnds,
        ),
      );

      addOns = cartServiceInterface.calculateAddonPrice(
        addOns,
        addOnList,
        cartModel,
      );

      variationPrice = cartServiceInterface.calculateVariationPrice(
        isFoodVariation,
        cartModel,
        discount,
        discountType,
        variationPrice,
      );

      variationWithoutDiscountPrice = cartServiceInterface
          .calculateVariationWithoutDiscountPrice(
            isFoodVariation,
            cartModel,
            variationWithoutDiscountPrice,
          );
      haveVariation = cartServiceInterface.checkVariation(
        isFoodVariation,
        cartModel,
      );

      double price = haveVariation
          ? variationWithoutDiscountPrice
          : (cartModel.item!.price! * cartModel.quantity!);
      double discountPrice = haveVariation
          ? (variationWithoutDiscountPrice - variationPrice)
          : (price -
                (PriceConverter.convertWithDiscount(
                      cartModel.item!.price!,
                      discount,
                      discountType,
                    )! *
                    cartModel.quantity!));

      itemPrice = itemPrice + price;
      itemDiscountPrice = itemDiscountPrice + discountPrice;

      haveVariation = false;
    }
    double subTotal = 0;
    if (isFoodVariation) {
      itemDiscountPrice =
          itemDiscountPrice + (variationWithoutDiscountPrice - variationPrice);
      variationPrice = variationWithoutDiscountPrice;
      subTotal = (itemPrice - itemDiscountPrice) + addOns + variationPrice;
    } else {
      subTotal = (itemPrice - itemDiscountPrice);
    }

    emit(
      state.copyWith(
        status: CartStatus.success,
        addOnsList: addOnsList,
        availableList: availableList,
        itemPrice: itemPrice,
        itemDiscountPrice: itemDiscountPrice,
        addOns: addOns,
        variationPrice: variationPrice,
        subTotal: subTotal,
      ),
    );
  }

  void _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) async {
    final newCartList = List<Cart>.from(state.cartList);
    if (event.index != null && event.index != -1) {
      newCartList[event.index!] = event.cartModel;
    } else {
      newCartList.add(event.cartModel);
    }
    emit(state.copyWith(cartList: newCartList));
    addSharedPrefCartListUseCase(newCartList);
    add(CalculationCartEvent());
  }

  void _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final cartId = state.cartList[event.cartIndex].id;
    final newCartList = List<Cart>.from(state.cartList);
    newCartList.removeAt(event.cartIndex);
    emit(state.copyWith(cartList: newCartList));
    addSharedPrefCartListUseCase(newCartList);
    add(CalculationCartEvent());

    if (cartId != null) {
      await deleteCartUseCase(id: cartId);
    }
  }

  void _onSetQuantity(SetQuantityEvent event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true));
    final newCartList = List<Cart>.from(state.cartList);
    final moduleStock =
        ModuleHelper.getModuleConfig(event.cart.item?.moduleType).stock ??
        false;
    final stock = event.cart.item?.stock ?? 0;

    newCartList[event.cartIndex].quantity = cartServiceInterface
        .decideItemQuantity(
          event.isIncrement,
          newCartList,
          event.cartIndex,
          stock,
          event.cart.item?.quantityLimit,
          moduleStock,
        );

    emit(state.copyWith(cartList: newCartList, isLoading: false));
    addSharedPrefCartListUseCase(newCartList);
    add(CalculationCartEvent());

    if (newCartList[event.cartIndex].id != null) {
      double discountedPrice = cartServiceInterface.calculateDiscountedPrice(
        newCartList[event.cartIndex],
        newCartList[event.cartIndex].quantity!,
        ModuleHelper.getModuleConfig(
              newCartList[event.cartIndex].item?.moduleType,
            ).newVariation ??
            false,
      );
      await updateCartQuantityOnlineUseCase(
        cartId: newCartList[event.cartIndex].id!,
        price: discountedPrice,
        quantity: newCartList[event.cartIndex].quantity!,
      );
    }
  }

  void _onClearCart(ClearCartEvent event, Emitter<CartState> emit) async {
    emit(state.copyWith(cartList: const []));
    addSharedPrefCartListUseCase(const []);
    add(CalculationCartEvent());
    if ((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) &&
        (ModuleHelper.getModule() != null ||
            ModuleHelper.getCacheModule() != null)) {
      await deleteCartUseCase(id: null, isRemoveAll: true);
    }
  }

  // Helper methods to maintain compatibility with legacy UI during migration
  Future<bool> addToCartOnline(dynamic cartModel) async {
    // Map dynamic model to entity
    final cart = OnlineCart(
      id: cartModel.cartId,
      itemId: cartModel.itemId,
      price: cartModel.price,
      foodVariation: null, // map if needed
      quantity: cartModel.quantity,
      addOnIds: cartModel.addOnIds,
      addOnQtys: cartModel.addOnQtys,
      itemType: cartModel.itemType,
    );
    final result = await addToCartOnlineUseCase(cart);
    return result.fold((failure) => false, (success) {
      add(GetCartDataEvent());
      return true;
    });
  }

  Future<bool> updateCartOnline(dynamic cart) async {
    // Assuming toJson maps properly
    final result = await updateCartOnlineUseCase(cart.toJson());
    return result.fold((failure) => false, (success) {
      add(GetCartDataEvent());
      return true;
    });
  }

  Future<bool> clearCartOnline() async {
    final result = await deleteCartUseCase(id: null, isRemoveAll: true);
    return result.fold((failure) => false, (success) {
      add(GetCartDataEvent());
      return true;
    });
  }
}
