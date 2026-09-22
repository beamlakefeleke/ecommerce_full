import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/checkout/domain/models/place_order_body_model.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository_new.dart';

class PlaceOrderUseCase {
  final CheckoutRepositoryNew _repository;
  const PlaceOrderUseCase(this._repository);

  Future<Either<Failure, String>> call(
    PlaceOrderBodyModel body,
    XFile? attachment,
  ) =>
      _repository.placeOrder(body, attachment);
}
