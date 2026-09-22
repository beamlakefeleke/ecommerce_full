import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/cart/domain/entities/cart.dart';
import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';

class AddSharedPrefCartListUseCase {
  final CartRepository repository;

  AddSharedPrefCartListUseCase(this.repository);

  Future<Either<Failure, void>> call(List<Cart> cartProductList) async {
    return await repository.addSharedPrefCartList(cartProductList);
  }
}
