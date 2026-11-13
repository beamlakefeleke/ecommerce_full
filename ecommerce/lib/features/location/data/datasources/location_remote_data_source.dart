import 'package:get/get_connect/connect.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/location/domain/entities/zone_response.dart';
import 'package:ecommerce/features/location/domain/models/prediction_model.dart';
import 'package:ecommerce/features/location/domain/models/zone_model.dart';
import 'package:ecommerce/features/parcel/domain/models/place_details_model.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Raw API access for the location feature. Throws [ServerException] /
/// [NetworkException]; the repository converts these to [Failure]s.
abstract class LocationRemoteDataSource {
  Future<String> getAddressFromGeocode(LatLng latLng);
  Future<ZoneResult> getZone(String? lat, String? lng, {bool handleError = false});
  Future<List<PredictionModel>> searchLocation(String text);
  Future<LatLng> getLatLng(String? placeId);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final ApiClient apiClient;

  LocationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<String> getAddressFromGeocode(LatLng latLng) async {
    final Response response = await apiClient.getData(
      '${AppConstants.geocodeUri}?lat=${latLng.latitude}&lng=${latLng.longitude}',
      handleError: false,
    );
    if (response.statusCode == 200 && response.body['status'] == 'OK') {
      return response.body['results'][0]['formatted_address'].toString();
    }
    if (response.statusCode == 200) {
      // Reached the server but geocoding failed (e.g. no result). Surface the
      // provider message so the repository can map it to a ServerFailure.
      throw ServerException(
        response.body['error_message']?.toString() ??
            response.bodyString ??
            'Unknown Location Found',
      );
    }
    throw _exceptionFor(response);
  }

  @override
  Future<ZoneResult> getZone(
    String? lat,
    String? lng, {
    bool handleError = false,
  }) async {
    final Response response = await apiClient.getData(
      '${AppConstants.zoneUri}?lat=$lat&lng=$lng',
      handleError: handleError,
    );
    if (response.statusCode == 200) {
      final zone = ZoneModel.fromJson(response.body);
      return ZoneResult(
        isSuccess: true,
        message: '',
        zoneIds: zone.zoneIds ?? [],
        zoneData: zone.zoneData ?? [],
        areaIds: const [],
      );
    }
    // The legacy repo returned a non-success ZoneResponseModel (not an
    // exception) for non-200 zone lookups, because "out of zone" is a normal
    // business outcome rather than an error. Preserve that: carry the status
    // text as an unsuccessful result instead of throwing.
    return ZoneResult(
      isSuccess: false,
      message: response.statusText,
      zoneIds: const [],
      zoneData: const [],
      areaIds: const [],
    );
  }

  @override
  Future<List<PredictionModel>> searchLocation(String text) async {
    final Response response = await apiClient.getData(
      '${AppConstants.searchLocationUri}?search_text=$text',
      handleError: false,
    );
    if (response.statusCode == 200 && response.body['status'] == 'OK') {
      final List<PredictionModel> predictions = [];
      response.body['predictions'].forEach(
        (prediction) => predictions.add(PredictionModel.fromJson(prediction)),
      );
      return predictions;
    }
    if (response.statusCode == 200) {
      throw ServerException(
        response.body['error_message']?.toString() ??
            response.bodyString ??
            'Server error',
      );
    }
    throw _exceptionFor(response);
  }

  @override
  Future<LatLng> getLatLng(String? placeId) async {
    final Response response = await apiClient.getData(
      '${AppConstants.placeDetailsUri}?placeid=$placeId',
      handleError: false,
    );
    if (response.statusCode == 200) {
      final placeDetails = PlaceDetailsModel.fromJson(response.body);
      if (placeDetails.status == 'OK') {
        return LatLng(
          placeDetails.result!.geometry!.location!.lat!,
          placeDetails.result!.geometry!.location!.lng!,
        );
      }
      return const LatLng(0, 0);
    }
    throw _exceptionFor(response);
  }

  Exception _exceptionFor(Response response) {
    if (response.statusCode == null ||
        response.statusCode == 0 ||
        response.statusCode == 1) {
      return NetworkException(response.statusText ?? 'No internet connection');
    }
    return ServerException(response.statusText ?? 'Server error');
  }
}
