import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';

/// Abstract contract for the search feature. Returns `Either<Failure, T>`;
/// raw exceptions never cross this boundary. Local (synchronous) operations
/// are exposed directly (no failure path needed for SharedPrefs reads).
abstract class SearchRepository {
  Future<Either<Failure, List<Item>>> searchItems(String query);
  Future<Either<Failure, List<Store>>> searchStores(String query);
  Future<Either<Failure, List<Item>>> getSuggestedItems();

  // Local — synchronous, no failure path.
  List<String> getSearchHistory();
  Future<void> saveSearchHistory(List<String> history);
  Future<void> clearSearchHistory();
}
