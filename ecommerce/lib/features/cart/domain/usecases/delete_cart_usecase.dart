import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';

class DeleteCartUseCase {
  final CartRepository repository;

  DeleteCartUseCase(this.repository);

  Future<Either<Failure, bool>> call({required int? id, bool isRemoveAll = false}) async {
    return await repository.deleteCart(id, isRemoveAll: isRemoveAll);
  }
}
