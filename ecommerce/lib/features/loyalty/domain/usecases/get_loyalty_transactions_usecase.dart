import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/loyalty/domain/entities/loyalty_transaction_page.dart';
import 'package:ecommerce/features/loyalty/domain/repositories/loyalty_repository.dart';

class GetLoyaltyTransactionsUseCase
    implements UseCase<LoyaltyTransactionPage, GetLoyaltyTransactionsParams> {
  final LoyaltyRepository repository;

  GetLoyaltyTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, LoyaltyTransactionPage>> call(
    GetLoyaltyTransactionsParams params,
  ) {
    return repository.getTransactions(params.offset);
  }
}

class GetLoyaltyTransactionsParams extends Equatable {
  final int offset;

  const GetLoyaltyTransactionsParams(this.offset);

  @override
  List<Object?> get props => [offset];
}
