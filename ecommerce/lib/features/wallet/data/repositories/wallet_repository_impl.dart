import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/common/models/transaction_model.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:ecommerce/features/wallet/data/models/fund_bonus_model.dart';
import 'package:ecommerce/features/wallet/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({required this.remoteDataSource});

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TransactionModel>> getWalletTransactionList(
          String offset, String sortingType) =>
      _guard(() => remoteDataSource.getWalletTransactionList(offset, sortingType));

  @override
  Future<Either<Failure, List<FundBonusModel>>> getWalletBonusList() =>
      _guard(() => remoteDataSource.getWalletBonusList());

  @override
  Future<Either<Failure, String>> addFundToWallet(
          double amount, String paymentMethod) =>
      _guard(() => remoteDataSource.addFundToWallet(amount, paymentMethod));

  @override
  Future<void> setWalletAccessToken(String token) =>
      remoteDataSource.setWalletAccessToken(token);

  @override
  String getWalletAccessToken() => remoteDataSource.getWalletAccessToken();
}
