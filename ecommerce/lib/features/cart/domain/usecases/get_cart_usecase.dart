import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/cart/data/models/online_cart_model.dart';
import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';

class GetCartUseCase implements UseCase<List<OnlineCartModel>, NoParams> {
  final CartRepository repository;
  GetCartUseCase(this.repository);

  @override
  Future<Either<Failure, List<OnlineCartModel>>> call(NoParams params) =>
      repository.getCartList();
}
