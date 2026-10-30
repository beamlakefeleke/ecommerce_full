import 'package:get/get_connect/connect.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/banner/data/models/banner_model.dart';
import 'package:ecommerce/features/banner/data/models/others_banner_model.dart';
import 'package:ecommerce/features/banner/data/models/promotional_banner_model.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Raw API access for the banner feature. Throws [ServerException] /
/// [NetworkException]; the repository converts these to [Failure]s.
abstract class BannerRemoteDataSource {
  Future<BannerModel> getBannerList();
  Future<BannerModel> getTaxiBannerList();
  Future<BannerModel> getFeaturedBannerList();
  Future<ParcelOtherBannerModel> getParcelOtherBannerList();
  Future<PromotionalBanner> getPromotionalBannerList();
}

class BannerRemoteDataSourceImpl implements BannerRemoteDataSource {
  final ApiClient apiClient;

  BannerRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<BannerModel> getBannerList() async {
    final Response response = await apiClient.getData(
      AppConstants.bannerUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return BannerModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<BannerModel> getTaxiBannerList() async {
    final Response response = await apiClient.getData(
      AppConstants.taxiBannerUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return BannerModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<BannerModel> getFeaturedBannerList() async {
    final Response response = await apiClient.getData(
      '${AppConstants.bannerUri}?featured=1',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return BannerModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<ParcelOtherBannerModel> getParcelOtherBannerList() async {
    final Response response = await apiClient.getData(
      AppConstants.parcelOtherBannerUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ParcelOtherBannerModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<PromotionalBanner> getPromotionalBannerList() async {
    final Response response = await apiClient.getData(
      AppConstants.promotionalBannerUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return PromotionalBanner.fromJson(response.body);
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
