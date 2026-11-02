import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/category/domain/entities/category.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';

/// Abstract contract for the category feature.
abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getCategories({
    bool allCategory = false,
  });
  Future<Either<Failure, List<Category>>> getSubCategories(String? parentId);
  Future<Either<Failure, ItemModel>> getCategoryItems(
    String? categoryId,
    int offset,
    String type,
  );
  Future<Either<Failure, StoreModel>> getCategoryStores(
    String? categoryId,
    int offset,
    String type,
  );
  Future<Either<Failure, dynamic>> searchData(
    String? query,
    String? categoryId,
    bool isStore,
    String type,
  );
  Future<Either<Failure, bool>> saveUserInterests(List<int?> interests);
}
