import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/features/search/domain/repositories/search_repository.dart';

class SearchItemsUseCase implements UseCase<List<Item>, String> {
  final SearchRepository repository;
  SearchItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Item>>> call(String query) =>
      repository.searchItems(query);
}

class SearchStoresUseCase implements UseCase<List<Store>, String> {
  final SearchRepository repository;
  SearchStoresUseCase(this.repository);

  @override
  Future<Either<Failure, List<Store>>> call(String query) =>
      repository.searchStores(query);
}

class GetSuggestedItemsUseCase implements UseCase<List<Item>, NoParams> {
  final SearchRepository repository;
  GetSuggestedItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Item>>> call(NoParams params) =>
      repository.getSuggestedItems();
}
