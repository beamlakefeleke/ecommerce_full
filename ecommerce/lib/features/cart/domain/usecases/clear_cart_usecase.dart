import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';

class ClearCartUseCase implements UseCase<bool, NoParams> {
  final CartRepository repository;
  ClearCartUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) => repository.clearCart();
}
