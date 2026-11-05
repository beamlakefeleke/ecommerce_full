import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository.dart';

class PlacePrescriptionOrderParams extends Equatable {
  final int? storeId;
  final double? distance;
  final String address;
  final String longitude;
  final String latitude;
  final String note;
  final List<XFile> orderAttachment;
  final String dmTips;
  final String deliveryInstruction;
  const PlacePrescriptionOrderParams({
    required this.storeId,
    required this.distance,
    required this.address,
    required this.longitude,
    required this.latitude,
    required this.note,
    required this.orderAttachment,
    required this.dmTips,
    required this.deliveryInstruction,
  });
  @override
  List<Object?> get props => [storeId, address, longitude, latitude, note];
}

class PlacePrescriptionOrderUseCase
    implements UseCase<PlaceOrderResult, PlacePrescriptionOrderParams> {
  final CheckoutRepository repository;
  PlacePrescriptionOrderUseCase(this.repository);

  @override
  Future<Either<Failure, PlaceOrderResult>> call(
    PlacePrescriptionOrderParams params,
  ) => repository.placePrescriptionOrder(
    storeId: params.storeId,
    distance: params.distance,
    address: params.address,
    longitude: params.longitude,
    latitude: params.latitude,
    note: params.note,
    orderAttachment: params.orderAttachment,
    dmTips: params.dmTips,
    deliveryInstruction: params.deliveryInstruction,
  );
}
