import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/features/search/data/datasources/search_local_data_source.dart';
import 'package:ecommerce/features/search/data/datasources/search_remote_data_source.dart';
import 'package:ecommerce/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;
  final SearchLocalDataSource localDataSource;

  SearchRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Item>>> searchItems(String query) async {
    try {
      final body = await remoteDataSource.searchItems(query);
      return Right(ItemModel.fromJson(body).items ?? []);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Store>>> searchStores(String query) async {
    try {
      final body = await remoteDataSource.searchStores(query);
      return Right(StoreModel.fromJson(body).stores ?? []);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Item>>> getSuggestedItems() async {
    try {
      final list = await remoteDataSource.getSuggestedItems();
      return Right(list);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  List<String> getSearchHistory() => localDataSource.getSearchHistory();

  @override
  Future<void> saveSearchHistory(List<String> history) =>
      localDataSource.saveSearchHistory(history);

  @override
  Future<void> clearSearchHistory() => localDataSource.clearSearchHistory();
}
