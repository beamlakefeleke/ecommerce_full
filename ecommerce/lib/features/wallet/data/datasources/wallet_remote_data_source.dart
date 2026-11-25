import 'package:get/get_connect/connect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/common/models/transaction_model.dart';
import 'package:ecommerce/features/wallet/data/models/fund_bonus_model.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:universal_html/html.dart' as html;
import 'package:get/get.dart' as getx;

abstract class WalletRemoteDataSource {
  Future<TransactionModel> getWalletTransactionList(
    String offset,
    String sortingType,
  );
  Future<List<FundBonusModel>> getWalletBonusList();
  Future<String> addFundToWallet(double amount, String paymentMethod);
  Future<void> setWalletAccessToken(String token);
  String getWalletAccessToken();
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  WalletRemoteDataSourceImpl({
    required this.apiClient,
    required this.sharedPreferences,
  });

  Exception _exceptionFor(Response response) {
    if (response.statusCode == null ||
        response.statusCode == 0 ||
        response.statusCode == 1) {
      return NetworkException(response.statusText ?? 'No internet connection');
    }
    return ServerException(
      response.body['message']?.toString() ??
          response.statusText ??
          'Server error',
    );
  }

  @override
  Future<TransactionModel> getWalletTransactionList(
    String offset,
    String sortingType,
  ) async {
    final Response response = await apiClient.getData(
      '${AppConstants.walletTransactionUri}?offset=$offset&limit=10&type=$sortingType',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return TransactionModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<FundBonusModel>> getWalletBonusList() async {
    final Response response = await apiClient.getData(
      AppConstants.walletBonusUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<FundBonusModel> list = [];
      response.body.forEach((v) => list.add(FundBonusModel.fromJson(v)));
      return list;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<String> addFundToWallet(double amount, String paymentMethod) async {
    String? hostname = html.window.location.hostname;
    String protocol = html.window.location.protocol;

    final Response response = await apiClient.postData(
      AppConstants.addFundUri,
      {
        'amount': amount,
        'payment_method': paymentMethod,
        'payment_platform': getx.GetPlatform.isWeb ? 'web' : '',
        'callback': '$protocol//$hostname${RouteHelper.wallet}',
      },
      handleError: false,
    );
    if (response.statusCode == 200) {
      return response.body['redirect_link']?.toString() ?? '';
    }
    throw _exceptionFor(response);
  }

  @override
  Future<void> setWalletAccessToken(String token) =>
      sharedPreferences.setString(AppConstants.walletAccessToken, token);

  @override
  String getWalletAccessToken() =>
      sharedPreferences.getString(AppConstants.walletAccessToken) ?? '';
}
