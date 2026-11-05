import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/checkout/data/models/place_order_body_model.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository.dart';

class PlaceOrderParams extends Equatable {
  final PlaceOrderBodyModel body;
  final XFile? orderAttachment;
  const PlaceOrderParams({required this.body, this.orderAttachment});
  @override
  List<Object?> get props => [body, orderAttachment];
}

class PlaceOrderUseCase implements UseCase<PlaceOrderResult, PlaceOrderParams> {
  final CheckoutRepository repository;
  PlaceOrderUseCase(this.repository);

  @override
  Future<Either<Failure, PlaceOrderResult>> call(PlaceOrderParams params) =>
      repository.placeOrder(params.body, params.orderAttachment);
}
