import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/common/models/transaction_model.dart';
import 'package:ecommerce/features/wallet/domain/repositories/wallet_repository_interface.dart';

class GetWalletTransactionsUseCase {
  final WalletRepositoryInterface repository;

  GetWalletTransactionsUseCase(this.repository);

  Future<Either<Failure, TransactionModel>> call({required String offset, required String walletType}) {
    return repository.getWalletTransactionList(offset, walletType);
  }
}
