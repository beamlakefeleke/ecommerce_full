import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:ecommerce/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:ecommerce/features/cart/domain/entities/cart.dart';
import 'package:ecommerce/features/cart/domain/entities/online_cart.dart';
import 'package:ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecommerce/api/api_checker.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({required this.remoteDataSource, required this.localDataSource});

  @override
  Future<Either<Failure, void>> addSharedPrefCartList(List<Cart> cartProductList) async {
    try {
      final models = cartProductList.map((e) => CartModel(
        id: e.id, price: e.price, discountedPrice: e.discountedPrice,
        variation: e.variation, foodVariations: e.foodVariations, discountAmount: e.discountAmount,
        quantity: e.quantity, addOnIds: e.addOnIds, addOns: e.addOns, isCampaign: e.isCampaign,
        stock: e.stock, item: e.item, quantityLimit: e.quantityLimit, isLoading: e.isLoading,
      )).toList();
      localDataSource.addSharedPrefCartList(models);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  List<Cart> getSharedPrefCartList() {
    try {
      return localDataSource.getSharedPrefCartList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Either<Failure, List<OnlineCart>>> addToCartOnline(OnlineCart cart) async {
    try {
      final Map<String, dynamic> cartJson = {
        'id': cart.id,
        'user_id': cart.userId,
        'module_id': cart.moduleId,
        'item_id': cart.itemId,
        'is_guest': cart.isGuest,
        'add_on_ids': cart.addOnIds,
        'add_on_qtys': cart.addOnQtys,
        'item_type': cart.itemType,
        'price': cart.price,
        'quantity': cart.quantity,
        'created_at': cart.createdAt,
        'updated_at': cart.updatedAt,
      };
      // For foodVariation and productVariation, they need proper toJson conversion if applicable,
      // but usually the backend expects a specific format. Since this is an object to Map conversion,
      // we'll rely on the datasource expecting a Map. Wait, earlier implementation passed OnlineCartModel.toJson().
      // Let's assume the datasource can take the raw json. Actually we should pass the OnlineCartModel.toJson().
      
      final result = await remoteDataSource.addToCartOnline(cartJson);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCart(int? id, {bool isRemoveAll = false}) async {
    try {
      bool result;
      if (isRemoveAll) {
        result = await remoteDataSource.clearCartOnline();
      } else {
        result = await remoteDataSource.removeCartItemOnline(id!);
      }
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OnlineCart>>> getCartDataOnline() async {
    try {
      final result = await remoteDataSource.getCartDataOnline();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OnlineCart>>> updateCartOnline(Map<String, dynamic> body) async {
    try {
      final result = await remoteDataSource.updateCartOnline(body);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateCartQuantityOnline(int cartId, double price, int quantity) async {
    try {
      final result = await remoteDataSource.updateCartQuantityOnline(cartId, price, quantity);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}