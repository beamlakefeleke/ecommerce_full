import 'package:get/get_connect/connect.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/loyalty/data/models/loyalty_transaction_model.dart';
import 'package:ecommerce/features/loyalty/domain/entities/loyalty_transaction_page.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Raw API access for the loyalty feature. Throws [ServerException] /
/// [NetworkException]; the repository converts these to [Failure]s. No GetX
/// `Response` type leaks above this layer.
abstract class LoyaltyRemoteDataSource {
  Future<LoyaltyTransactionPage> getTransactions(int offset);

  Future<void> pointToWallet(int point);
}

class LoyaltyRemoteDataSourceImpl implements LoyaltyRemoteDataSource {
  final ApiClient apiClient;

  LoyaltyRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<LoyaltyTransactionPage> getTransactions(int offset) async {
    final Response response = await apiClient.getData(
      '${AppConstants.loyaltyTransactionUri}?offset=$offset&limit=10',
      handleError: false,
    );
    if (response.statusCode == 200) {
      final body = response.body;
      final transactions = <dynamic>[];
      if (body['data'] != null) {
        for (final v in body['data']) {
          transactions.add(v);
        }
      }
      return LoyaltyTransactionPage(
        transactions: transactions
            .map((v) => LoyaltyTransactionModel.fromJson(v))
            .toList(),
        totalSize: body['total_size'] ?? 0,
      );
    }
    throw _exceptionFor(response);
  }

  @override
  Future<void> pointToWallet(int point) async {
    final Response response = await apiClient.postData(
      AppConstants.loyaltyPointTransferUri,
      {"point": point},
      handleError: false,
    );
    if (response.statusCode == 200) {
      return;
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
