import 'package:ecommerce/features/cart/domain/entities/cart.dart';
import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';

class GetSharedPrefCartListUseCase {
  final CartRepository repository;

  GetSharedPrefCartListUseCase(this.repository);

  List<Cart> call() {
    return repository.getSharedPrefCartList();
  }
}
