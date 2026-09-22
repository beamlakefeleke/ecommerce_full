import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/cart/domain/entities/online_cart.dart';
import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';

class UpdateCartOnlineUseCase {
  final CartRepository repository;

  UpdateCartOnlineUseCase(this.repository);

  Future<Either<Failure, List<OnlineCart>>> call(Map<String, dynamic> body) async {
    return await repository.updateCartOnline(body);
  }
}
