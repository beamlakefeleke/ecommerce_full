import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/cart/data/models/online_cart_model.dart';
import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecommerce/features/checkout/data/models/place_order_body_model.dart';

class UpdateCartParams extends Equatable {
  final OnlineCart cart;
  const UpdateCartParams(this.cart);
  @override
  List<Object?> get props => [cart];
}

class UpdateCartUseCase
    implements UseCase<List<OnlineCartModel>, UpdateCartParams> {
  final CartRepository repository;
  UpdateCartUseCase(this.repository);

  @override
  Future<Either<Failure, List<OnlineCartModel>>> call(
    UpdateCartParams params,
  ) => repository.updateCart(params.cart);
}
