import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository_new.dart';
import 'package:ecommerce/features/payment/domain/models/offline_method_model.dart';

class GetOfflineMethodsUseCase {
  final CheckoutRepositoryNew _repository;
  const GetOfflineMethodsUseCase(this._repository);

  Future<Either<Failure, List<OfflineMethodModel>>> call() =>
      _repository.getOfflineMethodList();
}
