import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/common/models/transaction_model.dart';
import 'package:ecommerce/features/wallet/domain/entities/fund_bonus.dart';

abstract class WalletRepositoryInterface {
  Future<Either<Failure, String>> addFundToWallet(double amount, String paymentMethod);
  Future<Either<Failure, TransactionModel>> getWalletTransactionList(String offset, String walletType);
  Future<Either<Failure, List<FundBonus>>> getWalletBonusList();
  
  void setWalletAccessToken(String token);
  String getWalletAccessToken();
}