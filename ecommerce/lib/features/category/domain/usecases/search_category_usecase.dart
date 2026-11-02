import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/category/domain/repositories/category_repository.dart';

class SearchCategoryParams extends Equatable {
  final String? query;
  final String? categoryId;
  final bool isStore;
  final String type;
  const SearchCategoryParams({
    required this.query,
    required this.categoryId,
    required this.isStore,
    required this.type,
  });
  @override
  List<Object?> get props => [query, categoryId, isStore, type];
}

class SearchCategoryUseCase implements UseCase<dynamic, SearchCategoryParams> {
  final CategoryRepository repository;
  SearchCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, dynamic>> call(SearchCategoryParams params) =>
      repository.searchData(
        params.query,
        params.categoryId,
        params.isStore,
        params.type,
      );
}
