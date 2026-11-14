import 'package:get/get_connect/connect.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/parcel/data/models/parcel_category_model.dart';
import 'package:ecommerce/features/parcel/data/models/parcel_instruction_model.dart';
import 'package:ecommerce/features/parcel/data/models/place_details_model.dart';
import 'package:ecommerce/features/parcel/data/models/video_content_model.dart';
import 'package:ecommerce/features/parcel/data/models/why_choose_model.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Raw API access for the parcel feature. Throws [ServerException] /
/// [NetworkException]; the repository converts these to [Failure]s. No GetX
/// `Response` type leaks above this layer.
///
/// The offline-methods / dm-tip / distance / place-order calls are NOT here —
/// those are served by the already-migrated [CheckoutRepository] (the legacy
/// `ParcelService` delegated them to the checkout repository too).
abstract class ParcelRemoteDataSource {
  Future<List<ParcelCategoryModel>> getParcelCategory();
  Future<List<Data>> getParcelInstruction(int offset);
  Future<WhyChooseModel?> getWhyChooseDetails();
  Future<VideoContentModel?> getVideoContentDetails();
  Future<PlaceDetailsModel> getPlaceDetails(String? placeId);
}

class ParcelRemoteDataSourceImpl implements ParcelRemoteDataSource {
  final ApiClient apiClient;

  ParcelRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ParcelCategoryModel>> getParcelCategory() async {
    final Response response = await apiClient.getData(
      AppConstants.parcelCategoryUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<ParcelCategoryModel> list = [];
      response.body.forEach(
        (parcel) => list.add(ParcelCategoryModel.fromJson(parcel)),
      );
      return list;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<Data>> getParcelInstruction(int offset) async {
    final Response response = await apiClient.getData(
      '${AppConstants.parcelInstructionUri}?limit=10&offset=$offset',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ParcelInstructionModel.fromJson(response.body).data ?? [];
    }
    throw _exceptionFor(response);
  }

  @override
  Future<WhyChooseModel?> getWhyChooseDetails() async {
    final Response response = await apiClient.getData(
      AppConstants.whyChooseUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return WhyChooseModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<VideoContentModel?> getVideoContentDetails() async {
    final Response response = await apiClient.getData(
      AppConstants.videoContentUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return VideoContentModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<PlaceDetailsModel> getPlaceDetails(String? placeId) async {
    final Response response = await apiClient.getData(
      '${AppConstants.placeDetailsUri}?placeid=$placeId',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return PlaceDetailsModel.fromJson(response.body);
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
