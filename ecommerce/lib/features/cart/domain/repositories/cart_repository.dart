import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/cart/domain/entities/cart.dart';
import 'package:ecommerce/features/cart/domain/entities/online_cart.dart';

abstract class CartRepository {
  Future<Either<Failure, void>> addSharedPrefCartList(List<Cart> cartProductList);
  List<Cart> getSharedPrefCartList();
  Future<Either<Failure, List<OnlineCart>>> addToCartOnline(OnlineCart cart);
  Future<Either<Failure, bool>> deleteCart(int? id, {bool isRemoveAll = false});
  Future<Either<Failure, List<OnlineCart>>> getCartDataOnline();
  Future<Either<Failure, List<OnlineCart>>> updateCartOnline(Map<String, dynamic> body);
  Future<Either<Failure, bool>> updateCartQuantityOnline(int cartId, double price, int quantity);
}
