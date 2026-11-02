import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:ecommerce/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:ecommerce/features/cart/data/models/cart_model.dart';
import 'package:ecommerce/features/cart/data/models/online_cart_model.dart';
import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecommerce/features/checkout/data/models/place_order_body_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<OnlineCartModel>>> addToCart(OnlineCart cart) =>
      _guard(() => remoteDataSource.addToCart(cart));

  @override
  Future<Either<Failure, List<OnlineCartModel>>> updateCart(OnlineCart cart) =>
      _guard(() => remoteDataSource.updateCart(cart));

  @override
  Future<Either<Failure, bool>> updateCartQuantity(
    int cartId,
    double price,
    int quantity,
  ) => _guard(
    () => remoteDataSource.updateCartQuantity(cartId, price, quantity),
  );

  @override
  Future<Either<Failure, List<OnlineCartModel>>> getCartList() =>
      _guard(() => remoteDataSource.getCartList());

  @override
  Future<Either<Failure, bool>> removeCartItem(int cartId) =>
      _guard(() => remoteDataSource.removeCartItem(cartId));

  @override
  Future<Either<Failure, bool>> clearCart() =>
      _guard(() => remoteDataSource.clearCart());

  @override
  Future<void> saveCartList(List<CartModel> cartList) =>
      localDataSource.saveCartList(cartList);

  @override
  List<CartModel> loadCartList() => localDataSource.loadCartList();

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
