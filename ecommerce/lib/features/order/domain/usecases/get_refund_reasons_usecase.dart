import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/order/domain/repositories/order_repository_new.dart';

class GetRefundReasonsUseCase {
  final OrderRepositoryNew _repository;
  const GetRefundReasonsUseCase(this._repository);

  Future<Either<Failure, List<String?>>> call() =>
      _repository.getRefundReasons();
}
