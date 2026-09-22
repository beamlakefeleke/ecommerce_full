import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/cart/domain/entities/online_cart.dart';
import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';

class AddToCartOnlineUseCase {
  final CartRepository repository;

  AddToCartOnlineUseCase(this.repository);

  Future<Either<Failure, List<OnlineCart>>> call(OnlineCart cart) async {
    return await repository.addToCartOnline(cart);
  }
}
