import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/cart/domain/entities/online_cart.dart';
import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';

class GetCartDataOnlineUseCase {
  final CartRepository repository;

  GetCartDataOnlineUseCase(this.repository);

  Future<Either<Failure, List<OnlineCart>>> call() async {
    return await repository.getCartDataOnline();
  }
}
