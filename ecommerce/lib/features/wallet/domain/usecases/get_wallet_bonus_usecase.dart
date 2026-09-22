import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/wallet/domain/entities/fund_bonus.dart';
import 'package:ecommerce/features/wallet/domain/repositories/wallet_repository_interface.dart';

class GetWalletBonusUseCase {
  final WalletRepositoryInterface repository;

  GetWalletBonusUseCase(this.repository);

  Future<Either<Failure, List<FundBonus>>> call() {
    return repository.getWalletBonusList();
  }
}
