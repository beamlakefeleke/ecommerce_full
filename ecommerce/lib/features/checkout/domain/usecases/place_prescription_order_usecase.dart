import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository_new.dart';

class PlacePrescriptionOrderUseCase {
  final CheckoutRepositoryNew _repository;
  const PlacePrescriptionOrderUseCase(this._repository);

  Future<Either<Failure, String>> call({
    required int? storeId,
    required double? distance,
    required String address,
    required String longitude,
    required String latitude,
    required String note,
    required List<MultipartBody> attachments,
    required String dmTips,
    required String deliveryInstruction,
  }) => _repository.placePrescriptionOrder(
    storeId,
    distance,
    address,
    longitude,
    latitude,
    note,
    attachments,
    dmTips,
    deliveryInstruction,
  );
}
