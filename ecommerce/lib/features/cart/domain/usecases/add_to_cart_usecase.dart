import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/cart/data/models/online_cart_model.dart';
import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecommerce/features/checkout/domain/models/place_order_body_model.dart';

class AddToCartParams extends Equatable {
  final OnlineCart cart;
  const AddToCartParams(this.cart);
  @override
  List<Object?> get props => [cart];
}

class AddToCartUseCase
    implements UseCase<List<OnlineCartModel>, AddToCartParams> {
  final CartRepository repository;
  AddToCartUseCase(this.repository);

  @override
  Future<Either<Failure, List<OnlineCartModel>>> call(AddToCartParams params) =>
      repository.addToCart(params.cart);
}
