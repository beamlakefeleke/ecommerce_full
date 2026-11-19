import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/payment/domain/repositories/payment_repository.dart';

class UpdateOfflineInfoUseCase implements UseCase<bool, String> {
  final PaymentRepository repository;

  UpdateOfflineInfoUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String data) =>
      repository.updateOfflineInfo(data);
}
