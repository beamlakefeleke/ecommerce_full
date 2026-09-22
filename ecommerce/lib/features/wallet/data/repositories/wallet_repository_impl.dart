import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/common/models/transaction_model.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/features/wallet/domain/models/fund_bonus_model.dart';
import 'package:ecommerce/features/wallet/domain/entities/fund_bonus.dart';
import 'package:ecommerce/features/wallet/domain/repositories/wallet_repository_interface.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:universal_html/html.dart' as html;

class WalletRepositoryImpl implements WalletRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  WalletRepositoryImpl({required this.apiClient, required this.sharedPreferences});

  @override
  Future<Either<Failure, String>> addFundToWallet(double amount, String paymentMethod) async {
    try {
      String? hostname = html.window.location.hostname;
      String protocol = html.window.location.protocol;

      Response response = await apiClient.postData(AppConstants.addFundUri,
        {
          "amount": amount,
          "payment_method": paymentMethod,
          "payment_platform": GetPlatform.isWeb ? 'web' : '',
          "callback": '$protocol//$hostname${RouteHelper.wallet}',
        }
      );

      if (response.statusCode == 200) {
        String redirectUrl = response.body['redirect_link'];
        return Right(redirectUrl);
      } else {
        return Left(ServerFailure(response.statusText ?? 'Failed to add fund'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TransactionModel>> getWalletTransactionList(String offset, String sortingType) async {
    try {
      Response response = await apiClient.getData('${AppConstants.walletTransactionUri}?offset=$offset&limit=10&type=$sortingType');
      if (response.statusCode == 200) {
        final transactionModel = TransactionModel.fromJson(response.body);
        return Right(transactionModel);
      } else {
        return Left(ServerFailure(response.statusText ?? 'Failed to fetch transactions'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FundBonus>>> getWalletBonusList() async {
    try {
      Response response = await apiClient.getData(AppConstants.walletBonusUri);
      if (response.statusCode == 200) {
        List<FundBonus> fundBonusList = [];
        response.body.forEach((value) {
          fundBonusList.add(FundBonusModel.fromJson(value));
        });
        return Right(fundBonusList);
      } else {
        return Left(ServerFailure(response.statusText ?? 'Failed to fetch bonus list'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  void setWalletAccessToken(String token) {
    sharedPreferences.setString(AppConstants.walletAccessToken, token);
  }

  @override
  String getWalletAccessToken() {
    return sharedPreferences.getString(AppConstants.walletAccessToken) ?? "";
  }
}