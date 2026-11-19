import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/payment/data/models/offline_method_model.dart';
import 'package:ecommerce/features/payment/domain/repositories/payment_repository.dart';

class GetOfflineMethodListUseCase
    implements UseCase<List<OfflineMethodModel>, NoParams> {
  final PaymentRepository repository;

  GetOfflineMethodListUseCase(this.repository);

  @override
  Future<Either<Failure, List<OfflineMethodModel>>> call(NoParams params) =>
      repository.getOfflineMethodList();
}
