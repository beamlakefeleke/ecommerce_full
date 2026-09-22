import 'package:fpdart/fpdart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/checkout/data/datasources/checkout_local_data_source.dart';
import 'package:ecommerce/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:ecommerce/features/checkout/domain/models/distance_model.dart';
import 'package:ecommerce/features/checkout/domain/models/place_order_body_model.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository_new.dart';
import 'package:ecommerce/features/payment/domain/models/offline_method_model.dart';

class CheckoutRepositoryImpl implements CheckoutRepositoryNew {
  final CheckoutRemoteDataSource _remote;
  final CheckoutLocalDataSource _local;

  const CheckoutRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<Failure, String>> placeOrder(
    PlaceOrderBodyModel orderBody,
    XFile? orderAttachment,
  ) async {
    try {
      final response = await _remote.placeOrder(orderBody, orderAttachment);
      if (response.statusCode == 200) {
        final orderID = response.body['order_id'].toString();
        return Right(orderID);
      }
      return Left(
        ServerFailure(
          response.statusText ?? 'Order placement failed',
          statusCode: response.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> placePrescriptionOrder(
    int? storeId,
    double? distance,
    String address,
    String longitude,
    String latitude,
    String note,
    List<MultipartBody> orderAttachment,
    String dmTips,
    String deliveryInstruction,
  ) async {
    try {
      final response = await _remote.placePrescriptionOrder(
        storeId,
        distance,
        address,
        longitude,
        latitude,
        note,
        orderAttachment,
        dmTips,
        deliveryInstruction,
      );
      if (response.statusCode == 200) {
        return Right(response.body['order_id'].toString());
      }
      return Left(
        ServerFailure(
          response.statusText ?? 'Prescription order failed',
          statusCode: response.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getDistanceInMeter(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      final response = await _remote.getDistanceInMeter(origin, destination);
      if (response.statusCode == 200 && response.body['status'] == 'OK') {
        final distance =
            DistanceModel.fromJson(
              response.body,
            ).rows![0].elements![0].duration!.value! /
            3600;
        return Right(distance);
      }
      // Fall back to straight-line distance
      final fallback =
          Geolocator.distanceBetween(
            origin.latitude,
            origin.longitude,
            destination.latitude,
            destination.longitude,
          ) /
          1000;
      return Right(fallback);
    } catch (e) {
      // Still return a fallback on exception rather than a hard failure
      try {
        final fallback =
            Geolocator.distanceBetween(
              origin.latitude,
              origin.longitude,
              destination.latitude,
              destination.longitude,
            ) /
            1000;
        return Right(fallback);
      } catch (_) {
        return Left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, double>> getExtraCharge(double? distance) async {
    try {
      final response = await _remote.getExtraCharge(distance);
      if (response.statusCode == 200) {
        return Right(double.parse(response.body.toString()));
      }
      return const Right(0.0);
    } catch (e) {
      return const Right(0.0);
    }
  }

  @override
  Future<Either<Failure, int>> getMostTippedAmount() async {
    try {
      final response = await _remote.getMostTippedAmount();
      if (response.statusCode == 200) {
        return Right(response.body['most_tips_amount'] as int? ?? 0);
      }
      return const Right(0);
    } catch (e) {
      return const Right(0);
    }
  }

  @override
  Future<Either<Failure, List<OfflineMethodModel>>>
  getOfflineMethodList() async {
    try {
      final response = await _remote.getOfflineMethodList();
      if (response.statusCode == 200) {
        final list = <OfflineMethodModel>[];
        for (final item in response.body as List) {
          list.add(OfflineMethodModel.fromJson(item));
        }
        return Right(list);
      }
      return Left(
        ServerFailure(
          response.statusText ?? 'Failed to load offline methods',
          statusCode: response.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> saveDmTipIndex(String index) => _local.saveDmTipIndex(index);

  @override
  String getDmTipIndex() => _local.getDmTipIndex();
}
