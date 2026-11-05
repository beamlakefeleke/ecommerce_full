import 'package:get/get_connect/connect.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/flash_sale/data/models/flash_sale_model.dart';
import 'package:ecommerce/features/flash_sale/data/models/product_flash_sale.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Raw API access for the flash-sale feature. Throws [ServerException] /
/// [NetworkException]; the repository converts these to [Failure]s.
abstract class FlashSaleRemoteDataSource {
  Future<FlashSaleModel> getFlashSale();
  Future<ProductFlashSale> getFlashSaleWithId(int id, int offset);
}

class FlashSaleRemoteDataSourceImpl implements FlashSaleRemoteDataSource {
  final ApiClient apiClient;

  FlashSaleRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<FlashSaleModel> getFlashSale() async {
    final Response response = await apiClient.getData(
      AppConstants.flashSaleUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return FlashSaleModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<ProductFlashSale> getFlashSaleWithId(int id, int offset) async {
    final Response response = await apiClient.getData(
      '${AppConstants.flashSaleProductsUri}?flash_sale_id=$id&offset=$offset&limit=10',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ProductFlashSale.fromJson(response.body);
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
