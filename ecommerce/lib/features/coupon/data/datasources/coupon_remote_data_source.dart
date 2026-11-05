import 'package:get/get_connect/connect.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/coupon/data/models/coupon_model.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Raw API access for the coupon feature. Throws [ServerException] /
/// [NetworkException]; the repository converts these to [Failure]s.
abstract class CouponRemoteDataSource {
  Future<List<CouponModel>> getCouponList();
  Future<List<CouponModel>> getTaxiCouponList();
  Future<CouponModel> applyCoupon(String couponCode, int? storeId);
  Future<CouponModel> applyTaxiCoupon(String couponCode, int? providerId);
}

class CouponRemoteDataSourceImpl implements CouponRemoteDataSource {
  final ApiClient apiClient;

  CouponRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CouponModel>> getCouponList() async {
    final Response response = await apiClient.getData(
      AppConstants.couponUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<CouponModel> coupons = [];
      response.body.forEach(
        (dynamic coupon) => coupons.add(CouponModel.fromJson(coupon)),
      );
      return coupons;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<CouponModel>> getTaxiCouponList() async {
    final Response response = await apiClient.getData(
      AppConstants.taxiCouponUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<CouponModel> coupons = [];
      response.body.forEach(
        (dynamic coupon) => coupons.add(CouponModel.fromJson(coupon)),
      );
      return coupons;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<CouponModel> applyCoupon(String couponCode, int? storeId) async {
    final Response response = await apiClient.getData(
      '${AppConstants.couponApplyUri}$couponCode&restaurant_id=$storeId',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return CouponModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<CouponModel> applyTaxiCoupon(
    String couponCode,
    int? providerId,
  ) async {
    final Response response = await apiClient.getData(
      '${AppConstants.taxiCouponApplyUri}$couponCode&provider_id=$providerId',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return CouponModel.fromJson(response.body);
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
