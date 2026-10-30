import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';

class UpdateCartQuantityParams extends Equatable {
  final int cartId;
  final double price;
  final int quantity;
  const UpdateCartQuantityParams({
    required this.cartId,
    required this.price,
    required this.quantity,
  });
  @override
  List<Object?> get props => [cartId, price, quantity];
}

class UpdateCartQuantityUseCase
    implements UseCase<bool, UpdateCartQuantityParams> {
  final CartRepository repository;
  UpdateCartQuantityUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpdateCartQuantityParams params) =>
      repository.updateCartQuantity(
        params.cartId,
        params.price,
        params.quantity,
      );
}
