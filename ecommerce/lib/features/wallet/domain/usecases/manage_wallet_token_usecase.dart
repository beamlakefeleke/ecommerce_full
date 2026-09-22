import 'package:ecommerce/features/wallet/domain/repositories/wallet_repository_interface.dart';

class ManageWalletTokenUseCase {
  final WalletRepositoryInterface repository;

  ManageWalletTokenUseCase(this.repository);

  void setWalletAccessToken(String token) {
    repository.setWalletAccessToken(token);
  }

  String getWalletAccessToken() {
    return repository.getWalletAccessToken();
  }
}
