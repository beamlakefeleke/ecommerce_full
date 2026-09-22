import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';

class UpdateCartQuantityOnlineUseCase {
  final CartRepository repository;

  UpdateCartQuantityOnlineUseCase(this.repository);

  Future<Either<Failure, bool>> call({required int cartId, required double price, required int quantity}) async {
    return await repository.updateCartQuantityOnline(cartId, price, quantity);
  }
}
