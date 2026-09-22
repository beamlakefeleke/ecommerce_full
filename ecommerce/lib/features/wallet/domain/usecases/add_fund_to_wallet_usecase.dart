import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/wallet/domain/repositories/wallet_repository_interface.dart';

class AddFundToWalletUseCase {
  final WalletRepositoryInterface repository;

  AddFundToWalletUseCase(this.repository);

  Future<Either<Failure, String>> call({required double amount, required String paymentMethod}) {
    return repository.addFundToWallet(amount, paymentMethod);
  }
}
