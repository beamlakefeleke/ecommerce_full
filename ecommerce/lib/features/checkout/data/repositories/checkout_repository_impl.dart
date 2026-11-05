import 'package:fpdart/fpdart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/checkout/data/datasources/checkout_local_data_source.dart';
import 'package:ecommerce/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:ecommerce/features/checkout/data/models/distance_model.dart';
import 'package:ecommerce/features/checkout/data/models/place_order_body_model.dart';
import 'package:ecommerce/features/checkout/domain/entities/time_slot.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:ecommerce/features/payment/domain/models/offline_method_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/helper/date_converter.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remoteDataSource;
  final CheckoutLocalDataSource localDataSource;

  CheckoutRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<OfflineMethodModel>>> getOfflineMethodList() =>
      _guard(() => remoteDataSource.getOfflineMethodList());

  @override
  Future<Either<Failure, int>> getDmTipMostTapped() =>
      _guard(() => remoteDataSource.getDmTipMostTapped());

  @override
  Future<Either<Failure, double>> getExtraCharge(double? distance) =>
      _guard(() => remoteDataSource.getExtraCharge(distance));

  @override
  Future<Either<Failure, double>> getDistanceInKm(
    LatLng origin,
    LatLng destination, {
    bool isDuration = false,
  }) async {
    try {
      final response = await remoteDataSource.getDistanceInMeter(
        origin,
        destination,
      );
      double distance;
      if (response.statusCode == 200 && response.body['status'] == 'OK') {
        if (isDuration) {
          distance =
              DistanceModel.fromJson(
                response.body,
              ).rows![0].elements![0].duration!.value! /
              3600;
        } else {
          distance = 25;
        }
      } else {
        distance = isDuration
            ? 0
            : Geolocator.distanceBetween(
                    origin.latitude,
                    origin.longitude,
                    destination.latitude,
                    destination.longitude,
                  ) /
                  1000;
      }
      return Right(distance);
    } catch (_) {
      final fallback = isDuration
          ? 0.0
          : Geolocator.distanceBetween(
                  origin.latitude,
                  origin.longitude,
                  destination.latitude,
                  destination.longitude,
                ) /
                1000;
      return Right(fallback);
    }
  }

  @override
  Future<Either<Failure, PlaceOrderResult>> placeOrder(
    PlaceOrderBodyModel body,
    XFile? orderAttachment,
  ) async {
    try {
      final response = await remoteDataSource.placeOrder(body, orderAttachment);
      if (response.statusCode == 200) {
        return Right(
          PlaceOrderResult(
            isSuccess: true,
            message: response.body['message'],
            orderId: response.body['order_id'].toString(),
          ),
        );
      }
      return Right(
        PlaceOrderResult(isSuccess: false, message: response.statusText),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PlaceOrderResult>> placePrescriptionOrder({
    required int? storeId,
    required double? distance,
    required String address,
    required String longitude,
    required String latitude,
    required String note,
    required List<XFile> orderAttachment,
    required String dmTips,
    required String deliveryInstruction,
  }) async {
    try {
      final List<MultipartBody> multiParts = orderAttachment
          .map((f) => MultipartBody('order_attachment[]', f))
          .toList();
      final Map<String, String> body = {
        'store_id': storeId.toString(),
        'distance': distance.toString(),
        'address': address,
        'longitude': longitude,
        'latitude': latitude,
        'order_note': note,
        'dm_tips': dmTips,
        'delivery_instruction': deliveryInstruction,
      };
      final response = await remoteDataSource.placePrescriptionOrder(
        body,
        multiParts,
      );
      if (response.statusCode == 200) {
        return Right(
          PlaceOrderResult(
            isSuccess: true,
            message: response.body['message'],
            orderId: response.body['order_id'].toString(),
          ),
        );
      }
      return Right(
        PlaceOrderResult(isSuccess: false, message: response.statusText),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  String getSharedPrefDmTipIndex() => localDataSource.getSharedPrefDmTipIndex();

  @override
  Future<bool> saveSharedPrefDmTipIndex(String index) =>
      localDataSource.saveSharedPrefDmTipIndex(index);

  @override
  List<TimeSlot> initializeTimeSlot(
    Store store,
    int? scheduleOrderSlotDuration,
  ) {
    final List<TimeSlot> timeSlots = [];
    final DateTime now = DateTime.now();
    for (int index = 0; index < store.schedules!.length; index++) {
      final openDate = DateConverter.convertStringTimeToDate(
        store.schedules![index].openingTime!,
      );
      final closeDate = DateConverter.convertStringTimeToDate(
        store.schedules![index].closingTime!,
      );
      final DateTime openTime = DateTime(
        now.year,
        now.month,
        now.day,
        openDate.hour,
        openDate.minute,
      );
      final DateTime closeTime = DateTime(
        now.year,
        now.month,
        now.day,
        closeDate.hour,
        closeDate.minute,
      );
      final int minutes = closeTime.difference(openTime).isNegative
          ? openTime.difference(closeTime).inMinutes
          : closeTime.difference(openTime).inMinutes;

      if (minutes > scheduleOrderSlotDuration!) {
        DateTime time = openTime;
        while (time.isBefore(closeTime)) {
          final DateTime start = time;
          DateTime end = start.add(
            Duration(minutes: scheduleOrderSlotDuration),
          );
          if (end.isAfter(closeTime)) end = closeTime;
          timeSlots.add(
            TimeSlot(
              day: store.schedules![index].day,
              startTime: start,
              endTime: end,
            ),
          );
          time = time.add(Duration(minutes: scheduleOrderSlotDuration));
        }
      } else {
        timeSlots.add(
          TimeSlot(
            day: store.schedules![index].day,
            startTime: openTime,
            endTime: closeTime,
          ),
        );
      }
    }
    return timeSlots;
  }

  @override
  List<TimeSlot> validateTimeSlot(
    List<TimeSlot> slots,
    int dateIndex,
    int? interval,
    bool orderPlaceToScheduleInterval,
  ) {
    final List<TimeSlot> timeSlots = [];
    DateTime now = DateTime.now();
    if (orderPlaceToScheduleInterval) {
      now = now.add(Duration(minutes: interval!));
    }
    int day = dateIndex == 0
        ? DateTime.now().weekday
        : DateTime.now().add(const Duration(days: 1)).weekday;
    if (day == 7) day = 0;
    for (final slot in slots) {
      if (day == slot.day &&
          (dateIndex == 0 ? slot.endTime!.isAfter(now) : true)) {
        timeSlots.add(slot);
      }
    }
    return timeSlots;
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
