import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/common/models/transaction_model.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/wallet/data/models/fund_bonus_model.dart';
import 'package:ecommerce/features/wallet/domain/repositories/wallet_repository.dart';

class TransactionListParams extends Equatable {
  final String offset;
  final String sortingType;
  const TransactionListParams({required this.offset, required this.sortingType});
  @override
  List<Object?> get props => [offset, sortingType];
}

class AddFundParams extends Equatable {
  final double amount;
  final String paymentMethod;
  const AddFundParams({required this.amount, required this.paymentMethod});
  @override
  List<Object?> get props => [amount, paymentMethod];
}

class GetWalletTransactionListUseCase
    implements UseCase<TransactionModel, TransactionListParams> {
  final WalletRepository repository;
  GetWalletTransactionListUseCase(this.repository);

  @override
  Future<Either<Failure, TransactionModel>> call(
          TransactionListParams params) =>
      repository.getWalletTransactionList(params.offset, params.sortingType);
}

class GetWalletBonusListUseCase
    implements UseCase<List<FundBonusModel>, NoParams> {
  final WalletRepository repository;
  GetWalletBonusListUseCase(this.repository);

  @override
  Future<Either<Failure, List<FundBonusModel>>> call(NoParams params) =>
      repository.getWalletBonusList();
}

class AddFundToWalletUseCase implements UseCase<String, AddFundParams> {
  final WalletRepository repository;
  AddFundToWalletUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(AddFundParams params) =>
      repository.addFundToWallet(params.amount, params.paymentMethod);
}
