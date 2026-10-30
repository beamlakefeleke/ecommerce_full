import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';

class RemoveCartItemUseCase implements UseCase<bool, int> {
  final CartRepository repository;
  RemoveCartItemUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(int params) =>
      repository.removeCartItem(params);
}
