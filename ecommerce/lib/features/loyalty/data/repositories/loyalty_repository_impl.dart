import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/loyalty/data/datasources/loyalty_remote_data_source.dart';
import 'package:ecommerce/features/loyalty/domain/entities/loyalty_transaction_page.dart';
import 'package:ecommerce/features/loyalty/domain/repositories/loyalty_repository.dart';

class LoyaltyRepositoryImpl implements LoyaltyRepository {
  final LoyaltyRemoteDataSource remoteDataSource;

  LoyaltyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, LoyaltyTransactionPage>> getTransactions(
    int offset,
  ) async {
    try {
      final page = await remoteDataSource.getTransactions(offset);
      return Right(page);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> pointToWallet(int point) async {
    try {
      await remoteDataSource.pointToWallet(point);
      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
