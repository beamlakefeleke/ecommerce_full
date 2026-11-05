import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:ecommerce/features/payment/domain/models/offline_method_model.dart';

class GetOfflineMethodsUseCase
    implements UseCase<List<OfflineMethodModel>, NoParams> {
  final CheckoutRepository repository;
  GetOfflineMethodsUseCase(this.repository);

  @override
  Future<Either<Failure, List<OfflineMethodModel>>> call(NoParams params) =>
      repository.getOfflineMethodList();
}
