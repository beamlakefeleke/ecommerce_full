import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/common/models/transaction_model.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/wallet/data/models/fund_bonus_model.dart';

abstract class WalletRepository {
  Future<Either<Failure, TransactionModel>> getWalletTransactionList(
    String offset,
    String sortingType,
  );
  Future<Either<Failure, List<FundBonusModel>>> getWalletBonusList();
  Future<Either<Failure, String>> addFundToWallet(
    double amount,
    String paymentMethod,
  );
  Future<void> setWalletAccessToken(String token);
  String getWalletAccessToken();
}
