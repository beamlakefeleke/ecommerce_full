import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/order/domain/repositories/order_repository_new.dart';

class SubmitRefundRequestUseCase {
  final OrderRepositoryNew _repository;
  const SubmitRefundRequestUseCase(this._repository);

  Future<Either<Failure, void>> call(Map<String, String> body, XFile? image) =>
      _repository.submitRefundRequest(body, image);
}
