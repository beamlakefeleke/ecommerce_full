import 'package:get/get_connect/connect.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/common/models/response_model.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/review/domain/models/review_body_model.dart';
import 'package:ecommerce/features/review/domain/models/review_model.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Raw API access for the review feature. Throws [ServerException] /
/// [NetworkException]; the repository converts these to [Failure]s.
abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getStoreReviewList(String? storeID);
  Future<ResponseModel> submitReview(ReviewBodyModel reviewBody);
  Future<ResponseModel> submitDeliveryManReview(ReviewBodyModel reviewBody);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final ApiClient apiClient;

  ReviewRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ReviewModel>> getStoreReviewList(String? storeID) async {
    final Response response = await apiClient.getData(
      '${AppConstants.storeReviewUri}?store_id=$storeID',
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<ReviewModel> list = [];
      response.body.forEach(
        (review) => list.add(ReviewModel.fromJson(review)),
      );
      return list;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<ResponseModel> submitReview(ReviewBodyModel reviewBody) async {
    final Response response = await apiClient.postData(
      AppConstants.reviewUri,
      reviewBody.toJson(),
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ResponseModel(true, 'review_submitted_successfully'.tr);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<ResponseModel> submitDeliveryManReview(
    ReviewBodyModel reviewBody,
  ) async {
    final Response response = await apiClient.postData(
      AppConstants.deliveryManReviewUri,
      reviewBody.toJson(),
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ResponseModel(true, 'review_submitted_successfully'.tr);
    }
    throw _exceptionFor(response);
  }

  Exception _exceptionFor(Response response) {
    // statusCode 0/1 are the ApiClient's "no internet" sentinels.
    if (response.statusCode == null ||
        response.statusCode == 0 ||
        response.statusCode == 1) {
      return NetworkException(response.statusText ?? 'No internet connection');
    }
    return ServerException(response.statusText ?? 'Server error');
  }
}
