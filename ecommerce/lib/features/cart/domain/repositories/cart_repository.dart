import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/cart/data/models/cart_model.dart';
import 'package:ecommerce/features/cart/data/models/online_cart_model.dart';
import 'package:ecommerce/features/checkout/data/models/place_order_body_model.dart';

/// Abstract cart repository. Implemented in the data layer.
abstract class CartRepository {
  // --- online operations ---
  Future<Either<Failure, List<OnlineCartModel>>> addToCart(OnlineCart cart);
  Future<Either<Failure, List<OnlineCartModel>>> updateCart(OnlineCart cart);
  Future<Either<Failure, bool>> updateCartQuantity(
    int cartId,
    double price,
    int quantity,
  );
  Future<Either<Failure, List<OnlineCartModel>>> getCartList();
  Future<Either<Failure, bool>> removeCartItem(int cartId);
  Future<Either<Failure, bool>> clearCart();

  // --- local (shared prefs) operations ---
  Future<void> saveCartList(List<CartModel> cartList);
  List<CartModel> loadCartList();
}
